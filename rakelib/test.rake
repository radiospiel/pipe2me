desc "Run tests"
task :test => %w(test:etest test:integration)

task :etest do
  system "env SIMPLE_COV=1 rake test:etest"
end

namespace :test do
  task :etest do
    require "etest-unit"
    module EmbeddedTests
      module Etest
        include Tunnel::Etest
        include Tunnel::FQDN::Etest
        include Tunnel::Token::Etest
        include Tunnel::Status::Etest
        include Tunnel::Check::Etest
        include Wordize::Etest
      end
    end

    ActiveRecord::Base.logger.level = Logger::INFO
    EmbeddedTests.etest
  end

  task :integration => "monit:configure" do
    system "monit stop all"
    system "monit start all"
    system "sleep 3"

    here = File.dirname(__FILE__)
    file = `gem which pipe2me/version.rb`.chomp
    dir = File.expand_path "#{File.dirname(file)}/../.."
    Dir.chdir dir do
      puts "Working in #{Dir.getwd}"
      FileUtils.mkdir_p "tmp"
      system "TEST_ENV=debug #{here}/../script/roundup test/*-test.sh"
    end
  end
end
