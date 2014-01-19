if File.exists?("#{VAR}/server.conf")
  load "#{VAR}/server.conf"
else
  UI.warn "Loading sample configuration"
  load "#{ROOT}/config/server.conf.example"
  UI.error "Note: make sure to create and edit a custom configuration in #{VAR}/server.conf, by running 'rake configure'"
end
