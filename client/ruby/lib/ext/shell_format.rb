require "shellwords"

module ShellFormat
  extend self

  def dump(obj, prefix=nil)
    format_entries([], obj, prefix).join
  end

  alias :shell :dump

  def parse(data)
    arrays = {}

    data.lines.inject({}) do |hsh, line|
      key, value = line.split(/\s*=\s*/, 2)
      value.gsub!(/\s*$/, "")
      value = Integer(value) rescue value

      if key =~ /^([^_]+)_(\d+)$/
        ary = arrays[$1] ||= []
        ary[$2.to_i] = value
        key, value = $1, ary
      end

      hsh.update key.downcase.to_sym => value
    end
  end

  private

  def format_entries(ary, obj, prefix)
    case obj
    when Array
      prefix = "#{prefix}_" if prefix
      obj.each_with_index do |entry, idx|
        format_entries ary, entry, "#{prefix}#{idx}"
      end
      ary
    when Hash
      prefix = "#{prefix}_" if prefix
      obj.each do |key, value|
        format_entries ary, value, "#{prefix}#{key.upcase}"
      end
      ary
    when defined?(ActiveRecord::Relation) ? ActiveRecord::Relation : nil
      format_entries(ary, obj.to_a, prefix)
    else
      if obj.respond_to?(:attributes)
        format_entries(ary, obj.attributes, prefix)
      else
        ary << "#{prefix}=#{Shellwords.escape(obj)}\n"
      end
    end
  end
end
