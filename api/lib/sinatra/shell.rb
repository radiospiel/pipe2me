require "shellwords"

# The Sinatra::Shell helper formats a hash suitable to be sourced
# into a Shell. Handle with care
module Sinatra::Shell
  SELF=self
  
  def self.format(obj, prefix)
    collect_entries([], obj, prefix).join
  end
  
  def self.collect_entries(ary, obj, prefix)
    case obj
    when Array 
      prefix = "#{prefix}_" if prefix
      obj.each_with_index do |entry, idx| 
        collect_entries ary, entry, "#{prefix}#{idx}"
      end
      ary
    when Hash
      prefix = "#{prefix}_" if prefix
      obj.each do |key, value| 
        collect_entries ary, value, "#{prefix}#{key.upcase}"
      end
      ary
    when defined?(ActiveRecord::Relation) ? ActiveRecord::Relation : nil
      collect_entries(ary, obj.to_a, prefix)
    else
      if obj.respond_to?(:attributes)
        collect_entries(ary, obj.attributes, prefix)
      else
        ary << "#{prefix}=#{Shellwords.escape(obj)}\n"
      end
    end
  end

  def shell(obj, prefix=nil)
    response.headers["Content-Type"] = "application/shell;charset=utf-8"

    prefix = self.class.name.gsub(/.*::/, "").upcase
    SELF.format(obj, prefix)
  end
end
