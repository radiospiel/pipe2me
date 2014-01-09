require 'rake/task.rb'

module Rake::Install
  def self.os_name
    @os_name ||= begin
      os_name = `uname`.chomp.downcase
      if os_name == "linux"
        if File.exist?("/etc/debian_version")
          os_name = "debian"
        end
      end
      os_name
    end
  end

  class Task < Rake::Task
    attr :canary, true

    def package
      self.name.split(":").last
    end

    def needed?
      if canary.starts_with?("/")
        if File.exists?(canary)
          STDERR.puts "Using #{canary}"
          false
        else
          STDERR.puts "Missing #{canary}"
          true
        end
      else
        path = `which #{canary}`.chomp
        STDERR.puts "Using #{canary} in #{path}" if $?.exitstatus == 0
        STDERR.puts "Going to install #{package}" if $?.exitstatus != 0
        $?.exitstatus != 0
      end
    end

    def execute(arg=nil)
      raise "Cannot find #{package}"
      super
    end

    def sys(cmd)
      STDERR.puts cmd
      system cmd
      raise "Command failed: #{cmd}" if $?.exitstatus != 0
    end

    def self.define_tasks(*names, &block)
      names.each do |name|
        if name.is_a?(Hash)
          name.each do |package, canary|
            task = define_task(package, &block)
            task.canary = canary
          end
        else
          task = define_task(name, &block)
          task.canary = name
        end
      end
    end
  end

  class AptTask < Task
    def execute(arg=nil)
      sys "sudo apt-get install #{package}"
      super
    end
  end

  class BrewTask < Task
    def execute(arg=nil)
      sys "brew install #{package}"
      super
    end
  end
end

module Rake::DSL
  def apt(*names, &block)
    Rake::Install::AptTask.define_tasks *names, &block
  end

  def brew(*names, &block)
    Rake::Install::BrewTask.define_tasks *names, &block
  end

  def binary(*names, &block)
    Rake::Install::Task.define_tasks *names, &block
  end

  def packages(name, *names, &block)
    task = Rake::Task.define_task(name)
    task.enhance names.map { |name| "install:#{Rake::Install.os_name}:#{name}" }
    task
  end
end
