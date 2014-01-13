desc "Run tests"
task :test => %w(test:etest test:integration)

namespace :test do
  task :etest do
    require "etest-unit"
    Subdomain.etest
  end

  task :integration => "monit:configure" do
    system "monit stop all"
    system "monit start all"
    system "sleep 3"
    system "cd ~/pipe2me-client/bin; rake"
  end
end
