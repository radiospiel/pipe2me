namespace :monit do
  desc "Create monitrc file"
  task :configure do
    require_relative "erb_ext"

    PIDDIR = "#{VAR}/pids"
    LOGDIR = "#{VAR}/log"
    BUNDLE = "#{ROOT}/script/bundle"
    FileUtils.mkdir PIDDIR unless File.exists?(PIDDIR)
    FileUtils.mkdir LOGDIR unless File.exists?(LOGDIR)

    if File.exists?("monitrc")
      FileUtils.cp "monitrc", "monitrc.old"
    end

    ERB.process "config/monitrc.erb" => "#{VAR}/config/monitrc"
    FileUtils.chmod 0600, "#{VAR}/config/monitrc"
    Sys.sys! "monit", "-c", "#{VAR}/config/monitrc", "-t"
    FileUtils.ln_sf "#{VAR}/config/monitrc", "monitrc"
  end
end
