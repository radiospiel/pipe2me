namespace :monit do
  desc "Create monitrc file"
  task :configure do
    require_relative "erb_ext"

    PIDDIR = "#{ROOT}/var/pids"
    LOGDIR = "#{ROOT}/var/log"
    BUNDLE = "#{ROOT}/script/bundle"
    FileUtils.mkdir_p PIDDIR
    FileUtils.mkdir_p LOGDIR

    if File.exists?("monitrc")
      FileUtils.cp "monitrc", "monitrc.old"
    end

    ERB.process "config/monitrc.erb" => "var/config/monitrc"
    FileUtils.chmod 0600, "var/config/monitrc"
    Sys.sys! "monit", "-c", "var/config/monitrc", "-t"
    FileUtils.ln_sf "var/config/monitrc", "monitrc"
  end
end
