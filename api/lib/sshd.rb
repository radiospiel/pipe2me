require "sys"
require "ui"
require "ext/file_ext"

module SSHD
  extend self

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

  # -- paths ------------------------------------------------------------------

  def path(*parts); File.join ROOT, "var", "sshd", *parts.map(&:to_s); end

  # -- sshd_config ------------------------------------------------------------

  def write_config
    erb = ERB.new File.read(__FILE__.gsub(/\.rb$/, ".conf.erb"))
    config = erb.result binding
    File.atomic_write path(:sshd_config), config
    STDERR.puts "Created #{path(:sshd_config)}"
  end

  # -- authorized_keys --------------------------------------------------------

  def write_authorized_keys
    File.atomic_write path(:authorized_keys), authorized_keys
    STDERR.puts "Created #{path(:authorized_keys)}"
  end

  private

  # create the data for the authorized_keys file.

  def authorized_keys(subdomains = Subdomain.all)
    subdomains.
      with_ssh_keys.
      includes(:ports).
      map { |subdomain| authorized_keys_line(subdomain) }.
      compact.
      join("\n")
  end

  # AUTHORIZED_KEYS_OPTIONS disable a number of sshd options, that are
  # usually enabled by default. For some reason we need a pty, at least
  # on some systems (Debian).
  AUTHORIZED_KEYS_OPTIONS = %w(
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
  def authorized_keys_line(subdomain)
    return unless subdomain.ssh_public_key?

    options = AUTHORIZED_KEYS_OPTIONS.grep(/^[^#]/)
    options += subdomain.ports.map { |port|  "permitopen=\":#{port.port}\"" }

    "#{options.join(",")} #{subdomain.ssh_public_key}"
  end
end
