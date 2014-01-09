namespace :monit do
  desc "Create monitrc file"
  task :configure do
    require_relative "procfile"
    require_relative "erb_ext"

    PIDDIR = "#{ROOT}/var/pids"
    BUNDLE = "#{ROOT}/script/bundle"
    FileUtils.mkdir_p PIDDIR

    ERB.process "config/monitrc.erb" => "var/config/monitrc"
    FileUtils.chmod 0600, "var/config/monitrc"
    FileUtils.ln_sf "var/config/monitrc", "."
  end
end
