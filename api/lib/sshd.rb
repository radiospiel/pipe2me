require "sys"
require "ui"
require "ext/file_ext"

module SSHD
  extend self

  attr :root, true
  attr :listen_address, true

  def user
    @user ||= `whoami`.chomp
  end

  # generate a SSH keypair for a specific name, and return the
  # public and private key.
  def keygen(name)
    UI.benchmark "[#{name}] create ssh identity" do
      Dir.mktmpdir do |dir|
        Sys.sys! "ssh-keygen",
           "-f", "#{dir}/id_rsa",
           "-t", "rsa",
           "-C", name,
           "-N", ""

        [ File.read("#{dir}/id_rsa.pub"), File.read("#{dir}/id_rsa") ]
      end
    end
  end

  # start a SSHD server.

  def exec
    # -- create sshd path --------------------------------
    unless Dir.exists? path(:sshd_dir)
      FileUtils.mkdir_p path(:sshd_dir)
    end

    # -- create sshd host_key
    unless File.exists? path(:host_key)
      Sys.sys! "ssh-keygen", "-t", "rsa", "-f", SSHD.path(:host_key), "-N", ''
    end

    # -- write config and authorized_keys

    write_config
    write_authorized_keys

    command = [ "/usr/sbin/sshd", "-D", "-e", "-f", SSHD.path(:sshd_config) ]
    STDERR.puts "Running #{command.join(" ")}"
    Kernel.exec *command
  end

  # -- paths ------------------------------------------------------------------

  def path(*parts)
    File.join root, *parts.map(&:to_s)
  end

  # -- sshd_config ------------------------------------------------------------

  def write_config
    template = File.join File.dirname(__FILE__), "sshd.conf.erb"
    erb = ERB.new File.read(template)
    config = erb.result binding
    File.atomic_write path(:sshd_config), config
    STDERR.puts "Created #{path(:sshd_config)}"
  end

  # write the authorized_keys file.
  #
  # This method rewrites the authorized_keys file.
  def write_authorized_keys
    subdomains = Subdomain.with_ssh_keys.includes(:ports)
    authorized_keys = subdomains.
      map { |subdomain| authorized_key(subdomain) }

    File.atomic_write path(:authorized_keys), authorized_keys.compact.join("\n")
    STDERR.puts "Created #{path(:authorized_keys)}"
  end

  private

  # AUTHORIZED_KEY_OPTIONS disable a number of sshd options, that are
  # usually enabled by default. For some reason we need a pty, at least
  # on some systems (Debian).
  AUTHORIZED_KEY_OPTIONS = %w(
    command="/bin/false"
    no-agent-forwarding
    #no-pty
    no-user-rc
    no-X11-forwarding
  )

  # returns a single line for the authorized_keys file. For details see
  # sshd(8), but a quick remark: a line looks like this:
  #
  #  option,option,option.. pub_key_data name
  #
  # and the options declare which ports may be used for which public key.
  def authorized_key(subdomain)
    return unless subdomain.ssh_public_key?

    options = AUTHORIZED_KEY_OPTIONS.grep(/^[^#]/)
    options += subdomain.ports.map { |port|  "permitopen=\":#{port.port}\"" }

    "#{options.join(",")} #{subdomain.ssh_public_key}"
  end
end
