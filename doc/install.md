## Installing your own pipe2me server (TL;DR)

- Have a user account
- Have ruby version 2, git, monit, daemon, nginx installed
- Run these:

        git clone https://github.com/kinkome/pipe2me.git
        cd pipe2me
        bundle install
        rake configure
        # edit var/server.conf, at least change TUNNEL_DOMAIN
        rake start

## Installing your own pipe2me server (extended version)

### Add a user for the pipe2me server

<pre>
root@test.pipe2.me:/# <b>adduser pipe2me</b>
Adding user `pipe2me' ...
...
</pre>

We strongly recommend using keybased authentication with your server. Go back
to your machine and upload your ssh pubkey (`ssh-copy-id pipe2me@test.pipe2.me`).
Then disable password-based authentication for this account. (Run as root: `passwd -d pipe2me`)

### Installing additional prerequisites

Log in as root and make sure these binaries are installed:

<pre>
root@test.pipe2.me:/# <b>apt-get upgrade</b>
root@test.pipe2.me:/# <b>apt-get update</b>
root@test.pipe2.me:/# <b>apt-get install daemon monit nginx git</b>
</pre>

### Installing ruby 2 on Debian

Log back in as your regular user account ("pipe2me"), and make sure you
have a ruby version 2. If not, install it. (See below)

<pre>
# verify ruby version
user@test.pipe2.me:~$ <b>ruby -v</b>
</pre>

pipe2me is developed under MRI ruby version 2.0 on Debian. Other rubies and
other systems might or might not work. You have been warned!

To install ruby2 on Debian we are using *rvm*. Now log in with your regular
user account ("pipe2me") and install rvm and ruby.

<pre>
user@test.pipe2.me:~$ <b>\curl -sSL https://get.rvm.io | bash -s stable --ruby</b>
user@test.pipe2.me:~$ <b>source ~/.rvm/scripts/rvm</b>
user@test.pipe2.me:~$ <b>ruby -v</b>
ruby 2.1.0p0 (2013-12-25 revision 44422) [x86_64-linux]
</pre>

### Get source code

<pre>
~$ <b>git clone https://github.com/kinkome/pipe2me.git</b>
Cloning into 'pipe2me'...
remote: Counting objects: 1278, done.
remote: Compressing objects: 100% (600/600), done.
remote: Total 1278 (delta 626), reused 1278 (delta 626)
Receiving objects: 100% (1278/1278), 210.72 KiB | 332 KiB/s, done.
Resolving deltas: 100% (626/626), done.
</pre>

**Note:** If you plan to use read/write access, then you obviously clone from a git URL
of your repository:

<pre>
~$ <b>git clone git@github.com:kinkome/pipe2me.git</b>
</pre>

### Configure pipe2me application

First, install all ruby dependencies:

<pre>
~$ <b>cd pipe2me</b>
~/pipe2me$ <b>bundle install</b>
Fetching gem metadata from https://rubygems.org/.......
Fetching additional metadata from https://rubygems.org/..
Installing rake (10.1.1)
Installing i18n (0.6.9)
Using minitest (4.7.5)
...
</pre>

Now configure the application:

<pre>
~/pipe2me$ <b>rake configure</b>
</pre>

Review the generated configuration file `var/server.conf`. If you change any settings
rerun the configure step:

<pre>
~/pipe2me$ <b>rake configure</b>
</pre>

### Start the pipe2me server.

Now you are ready to fire up the pipe2me server.

<pre>
~/pipe2me$ <b>monit -c monitrc</b>
~/pipe2me$ <b>monit -c monitrc start all</b>
</pre>

### Changing the configuration

To change the configuration adjust the `var/server.conf` file accordingly. After that,
run these steps

<pre>
~/pipe2me$ <b>rake configure</b>
~/pipe2me$ <b>monit -c monitrc.old stop all</b>
~/pipe2me$ <b>monit -c monitrc reload</b>
~/pipe2me$ <b>monit -c monitrc start all</b>
</pre>

### DNS Configuration

A pipe2me server manages a number of subdomains for a given domain. This domain must
be configured in `TUNNEL_DOMAIN`. DNS for this domain must be configured so that both
the domain as any wildcard subdomain resolves to the pipe2me server. For example, the
`test.pipe2.me` DNS entries are configured like this:

<pre>
~ > dig  test.pipe2.me +noall +answer *.test.pipe2.me +noall +answer
; <<>> DiG 9.8.5-P1 <<>> test.pipe2.me +noall +answer *.test.pipe2.me +noall +answer
;; global options: +cmd
test.pipe2.me.		220	IN	A	146.185.137.78
*.test.pipe2.me.	563	IN	A	146.185.137.78
</pre>
