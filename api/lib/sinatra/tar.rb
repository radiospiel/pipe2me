require "rubygems/package"

Gem::Package::TarWriter
class Gem::Package::TarWriter
  # each entry in the tar file, headers as well as data entries, start at
  # 512-byte boundaries. The :fill_block method can be used to fill up
  # the current 512-byte block.
  def fill_block
    fill_bytes = (512 - (@io.pos % 512)) % 512
    UI.success "fill_bytes", fill_bytes
    @io.write "\0" * fill_bytes if fill_bytes > 0
  end

  private :fill_block

  def add_entry(name, data, options = {})
    check_closed

    name, prefix = split_name(name)

    options = options.reverse_merge(name: name,
                prefix: prefix,
                size: data.bytesize,
                mtime: Time.now)

    header = Gem::Package::TarHeader.new(options)
    @io.write header
    fill_block

    @io.write data
    fill_block

    self
  end
end

# The Sinatra::Shell helper formats a hash as a tar file.
module Sinatra::Tar
  SELF=self

  def self.add_tar_entries(tar, entries, options = {})
    prefix = options[:prefix]

    entries.each do |key, value|
      key = key.to_s
      path = options[:prefix] ? File.join(options[:prefix].to_s, key) : key

      case value
      when Hash
        add_tar_entries tar, value, :prefix => path
      when nil
      else
        tar.add_entry path, value.to_s, mode: 0644, mtime: Time.now
      end
    end
  end

  def tar(entries)
    raise ArgumentError, "Invalid entries: #{entries.inspect}" unless entries.is_a?(Hash)
    headers["Content-Type"] = "application/x-tar"

    s = ""
    Gem::Package::TarWriter.new(StringIO.new(s)) do |tar|
      SELF.add_tar_entries tar, entries, prefix: nil
    end
    s
  end
end
