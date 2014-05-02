namespace :configure do
  task :"3rdparty" do
    FileUtils.mkdir_p "vendor"
    system "make -C vendor -f ../Sourcefile"
  end

  # desc "Install dependencies"
  task :dependencies do
    binaries = %w(daemon monit sshd nginx)
    missing = binaries.select do |name|
      system "which #{name} > /dev/null"
      $?.exitstatus != 0
    end

    if missing.empty?
      UI.success "Found all binaries", *binaries
    else
      UI.error "Cannot find these binaries", *missing
      exit 1
    end
  end

  # desc "Create needed directories"
  task :directories => "#{VAR}/config"
  directory "#{VAR}/config" do
    FileUtils.mkdir "#{VAR}/config"
  end

  # desc "Create config file"
  task :files => "#{VAR}/server.conf"
  file "#{VAR}/server.conf" do
    system "cp #{ROOT}/config/server.conf.example #{VAR}/server.conf"
    UI.success "Created #{VAR}/server.conf, please adjust settings there."
  end

  task :files => "#{VAR}/tokens.conf"
  file "#{VAR}/tokens.conf" do
    system "cp #{ROOT}/config/tokens.conf.example #{VAR}/tokens.conf"
    UI.success "Created #{VAR}/tokens.conf, please review token settings."
  end
end
