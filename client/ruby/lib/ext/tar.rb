module Tar
  def self.extract(io, &block)
    require 'rubygems/package'

    Gem::Package::TarReader.new io do |tar|
      tar.each do |tarfile|
        yield tarfile.full_name, tarfile.read
      end
    end
  end
end
