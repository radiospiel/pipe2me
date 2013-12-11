require "sys"

module SSH
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
  
  private

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
    options += subdomain.ports.map { |port|  "permitopen=\":#{port}\"" }

    "#{options.join(",")} #{subdomain.ssh_public_key}"
  end

  public
  
  # create the data for the authorized_keys file.
  def authorized_keys(subdomains)
    subdomains.map do |subdomain|
      authorized_keys_line(subdomain)
    end.compact.join("\n")
  end

  # create the data for the authorized_keys file.
  
  def config(options)
    expect! options => {
      :pid_file => [String, nil],
      :sshd_dir => String
    }
    
    options[:pid_file] ||= File.join(options[:sshd_dir], "sshd.pid")

    template = File.read(__FILE__).split(/__END__\n/).last
    template.gsub(/\${{(.*)}}/) do |_|
      key = $1.underscore.to_sym
      options[key] || raise(ArgumentError, "Missing option #{key.inspect}")
    end
  end
end

__END__

# This sshd_config file is derived from the following OpenBSD default config 
# file, and is adapted for use with the kinko server
#
#	$OpenBSD: sshd_config,v 1.81 2009/10/08 14:03:41 markus Exp $

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/bin:/bin:/usr/sbin:/sbin

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options change a
# default value.

Port 4422
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

# The default requires explicit activation of protocol 1
#Protocol 2

# HostKey for protocol version 1
#HostKey /etc/ssh/ssh_host_key
# HostKeys for protocol version 2
HostKey ${{SSHD_DIR}}/host_rsa_key
# HostKey ${{SSHD_DIR}}/host_dsa_key

# Lifetime and size of ephemeral version 1 server key
#KeyRegenerationInterval 1h
#ServerKeyBits 1024

# Logging
# obsoletes QuietMode and FascistLogging
SyslogFacility AUTHPRIV
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin yes
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

#RSAAuthentication yes
#PubkeyAuthentication yes
#AuthorizedKeysFile	.ssh/authorized_keys
AuthorizedKeysFile	${{SSHD_DIR}}/authorized_keys

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#RhostsRSAAuthentication no
# similar for protocol version 2
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# RhostsRSAAuthentication and HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords both PasswordAuthentication and
# ChallengeResponseAuthentication must be set to "no".
#PasswordAuthentication no
#PermitEmptyPasswords no

# Change to no to disable s/key passwords
#ChallengeResponseAuthentication yes

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing, 
# and session processing. If this is enabled, PAM authentication will 
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
# Also, PAM will deny null passwords by default.  If you need to allow
# null passwords, add the "	nullok" option to the end of the
# securityserver.so line in /etc/pam.d/sshd.
#UsePAM yes
UsePAM no

#AllowAgentForwarding yes
AllowAgentForwarding no
#AllowTcpForwarding yes
#GatewayPorts no
GatewayPorts yes
#X11Forwarding no
#X11DisplayOffset 10
#X11UseLocalhost yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#UseLogin no
#UsePrivilegeSeparation yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS yes
PidFile ${{PID_FILE}}
#MaxStartups 10
#PermitTunnel no
#ChrootDirectory none

# pass locale information
AcceptEnv LANG LC_*

# no default banner path
#Banner none

# override default of no subsystems
#Subsystem	sftp	/usr/libexec/sftp-server
Subsystem	sftp /dev/null

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	ForceCommand cvs server
