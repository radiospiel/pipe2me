#!/usr/bin/env ruby
HERE = File.expand_path File.dirname(__FILE__)

require "test/unit"
ENV["PATH"] = "#{HERE}/../client/ruby/bin:#{ENV["PATH"]}"

module Pipe2me
  class TestCase < Test::Unit::TestCase
    def pipe2me(cmd, options = {})
      cmd = "pipe2me --config pipe2me-config #{cmd}"

      options.each do |key, value|
        cmd += " --#{key} #{value}"
      end

      # puts cmd
      `#{cmd}`
    end
  end
end

Dir.glob("#{HERE}/**/*_test.rb").sort.each do |file|
  puts file
  load file
end
