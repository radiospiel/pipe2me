class Exception
  (class << self; self; end).class_eval do
    attr :backtrace_filters, true

    def filter_backtrace(&block)
      backtrace_filters << block
    end
  end

  self.backtrace_filters = []

  unless instance_methods.include?(:original_backtrace)
    alias :original_backtrace :backtrace
  end

  def short_backtrace
    return unless backtrace = original_backtrace

    (Exception.backtrace_filters || []).inject(backtrace) do |backtrace, filter|
      case filter
      when Symbol
        Exception.send filter, backtrace
      else
        filter.call(backtrace)
      end
    end
  end

  alias :backtrace :short_backtrace

  def self.filter_system_lines(lines)
    lines = lines.map do |line|
      next "..." if line =~ /\/gems\//
      next "..." if line =~ /\/#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}\//
      line
    end

    r = []
    lines.each do |line|
      r << line if r.last != line
    end

    r.compact
  end

  self.backtrace_filters << :filter_system_lines
end
