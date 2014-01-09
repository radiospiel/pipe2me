module Procfile
  def self.each_group(path)
    File.readlines("Procfile").grep(/^[^#]*[a-zA-Z]/).each do |line|
      line.chomp!
      name, cmd = line.split(/:\s*/, 2)
      yield name, cmd
    end
  end

  def self.each(path, options = {})
    port = options[:port] || 5555

    each_group path do |name, cmd|
      concurrency = options[name.to_sym] || 1

      1.upto(concurrency).each do |idx|
        yield name, "#{name}#{idx}", cmd, port+idx-1
      end

      port += 100
    end
  end
end

namespace :monit do
  desc "Create monitrc file"
  task :monitrc => "nginx:configure" do
    monit_header = <<-MONITRC
set daemon 10
set httpd port {{port}} and use address localhost allow localhost
MONITRC

    monitrc = <<-MONITRC
check process {{name}} with pidfile {{pidfiles}}/{{name}}.pid
    start program = "{{daemon}} -N --name {{name}} --pidfiles {{pidfiles}} -- env PORT={{port}} {{bundle}} exec {{cmd}}" with timeout 60 seconds
    stop program = "{{daemon}} -N --name {{name}} --pidfiles {{pidfiles}} --stop"
    group {{group}}
MONITRC

    root = File.expand_path("#{File.dirname(__FILE__)}/..")
    pidfiles = "#{root}/var/pids"
    FileUtils.mkdir_p pidfiles

    options = {
      pidfiles: "#{root}/var/pids",
      bundle: "#{root}/script/bundle",
      daemon: `which daemon`.chomp
    }

    entries = ""
    add = lambda do |tmpl, opt = {}|
      opt = options.merge(opt)
      entry = tmpl.gsub(/{{([a-z]+)}}/) { |_| opt.fetch($1.to_sym) }
      entries.concat "#{entry}\n\n"
    end

    add.call monit_header, port: 5500

    Procfile.each "Procfile", port: 5501, web: 1 do |group, name, cmd, port|
      add.call monitrc, name: name, group: group, cmd: cmd, port: port
    end

    monitrc_file = File.expand_path("~/.monitrc")

    File.open monitrc_file, "w" do |io|
      io.write entries
    end
    FileUtils.chmod 0600, monitrc_file

    puts "Created file #{monitrc_file}"
  end
end
