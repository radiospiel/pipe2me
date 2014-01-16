desc "Run tests"
task :test => %w(test:etest test:integration)

namespace :test do
  task :etest do
    require "etest-unit"
    Tunnel.etest
  end

  task :integration => "monit:configure" do
    system "monit stop all"
    system "monit start all"
    system "sleep 3"

    file = `gem which pipe2me/version.rb`.chomp
    dir = File.expand_path "#{File.dirname(file)}/../.."
    Dir.chdir dir do
      puts "Working in #{Dir.getwd}"
      FileUtils.mkdir_p "tmp"
      system "TEST_ENV=debug roundup test/*-test.sh"
    end
  end
end
