require 'rake/task.rb'

module Rake::Install
  def self.os_name
    @os_name ||= `uname`.chomp.downcase
  end

  class Task < Rake::Task
    def binary
      self.name.split(":").last
    end

    def needed?
      path = `which #{binary}`.chomp
      STDERR.puts "Using #{binary} in #{path}" if $?.exitstatus == 0
      STDERR.puts "Going to install #{binary}" if $?.exitstatus != 0
      $?.exitstatus != 0
    end

    def execute(arg=nil)
      raise "Cannot find #{binary}"
      super
    end

    def sys(cmd)
      STDERR.puts cmd
      system cmd
      raise "Command failed: #{cmd}" if $?.exitstatus != 0
    end

    def self.define_tasks(*names, &block)
      names.each do |name|
        define_task(name, &block)
      end
    end
  end

  class AptTask < Task
    def execute(arg=nil)
      sys "apt-get install #{binary}"
      super
    end
  end

  class BrewTask < Task
    def execute(arg=nil)
      sys "brew install #{binary}"
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
