module Tar
  def self.extract(io, options = {})
    target = options[:target] || "."

    require 'rubygems/package'

    Gem::Package::TarReader.new io do |tar|
      tar.each do |tarfile|
        path = File.join target, tarfile.full_name

        FileUtils.mkdir_p File.dirname(path)
        File.open path, "wb" do |io|
          io.write tarfile.read
        end
      end
    end
  end
end
