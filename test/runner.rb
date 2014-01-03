#!/usr/bin/env ruby
HERE = File.dirname(__FILE__)
require "test/unit"
Dir.glob("#{HERE}/**/*_test.rb").sort.each do |file|
  puts file
  load file
end
