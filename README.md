# pipe2me

pipe2me lets you publish TCP services on the internet that are potentially running behind
a NATting proxy.

## Overview

pipe2me manages connections from clients to servers behind a NAT proxy. It allows to
access services that you provide on your hardware. pipe2me assigns custom port(s) to
your connection, provides a unique domain name and an openssl certificate bound to
that domain name.

This document uses these names for the involved machinery:

- **server**: the pipe2me server.
 computer which wants to connect
- **consumer**: a computer which wants to connect
- **pod**: a computer running a number of services that you want to publish.

Each pipe2me server instance manages a single domain (for example: pipe2.me) and its
subdomains (for example: pink-unicorn.pipe2.me). Each pod gets assigned a unique
subdomain.

pipe2me manages the DNS settings for the subdomain to allow for short-circuiting traffic
between consumers and pods if both are behind the same router without compromising
accessibility from consumers in other locations.

## pipe2me server

### Prerequisites

pipe2me is developed under MRI ruby version 2.0 on Debian. Other rubies and
other systems might or might not work. You have been warned!

To install ruby2 on Debian we are using *rvm*. In short, run as non-root:

    # make sure system is up-to-date
    sudo apt-get upgrade
    sudo apt-get update

    # install rvm
    curl -L https://get.rvm.io | bash -s stable
    source ~/.rvm/scripts/rvm

    # install ruby 2
    rvm install 2.0

    # verify ruby version
    ruby -v

### Installation

To download and install the server software:

    # get source from repository.
    git clone ...
    cd pipe2me

    # prepare server
    bundle install
    sudo bundle exec rake install

    # the var subdirectory contains runtime information, and should
    # be stored outside of the main directory. It should be kept in
    # either ~/pipe2me.var or in /var/pipe2me. We choose ~/pipe2me.var.
    mkdir -p ~/pipe2me.var
    [ -x var ] || ln -sf ~/pipe2me.var var

    # install dependencies. You might be asked for the root password,
    # when some binaries are missing and must be installed.
    bundle exec rake dependencies:install

    # initialize database
    bundle exec rake db:migrate

### Configuring the server

On startup the server reads its configuration from the file `~/pipe2me.server.conf`.
Note that this is a ruby file.

This file should contain the following settings:

- `TUNNEL_DOMAIN`: set the server hostname: Each server serves connections for
  subdomains of a specific domain. For example, set TUNNEL_DOMAIN to `tunnels.pipe2.test`
  to run tunnels with names like `pink-unicorn.tunnels.pipe2.test`.
- `TUNNEL_PORTS`: set the range of tunnels available for the server, e.g. "10000...15000"
- `DYNAMIC_DNS_SERVICE`: which service manages DNS settings? Only currently supported service is
  dnsimple.com; the DNS_SERVICE setting should be "dnsimple:<api_token>". See "Dynamic DNS Configuration"
  below.

An example configuration can be found in `doc/pipe2me.server.conf.example`.

### DNS Configuration

A pipe2me server manages a number of subdomains for a given domain. This domain must
be configured in `TUNNEL_DOMAIN`. DNS for this domain must be configured so that both
the domain as any wildcard subdomain resolves to the pipe2me server. For example, the
`test.pipe2.me` DNS entries are configured like this:

    ~ > dig  test.pipe2.me +noall +answer *.test.pipe2.me +noall +answer
    ; <<>> DiG 9.8.5-P1 <<>> test.pipe2.me +noall +answer *.test.pipe2.me +noall +answer
    ;; global options: +cmd
    test.pipe2.me.		220	IN	A	146.185.137.78
    *.test.pipe2.me.	563	IN	A	146.185.137.78

#### Dynamic DNS Configuration

We recommend combining pipe2me with a dynamic DNS service. This lets clients "short-cut" the
connection to a pod if

- both live in the same network,
- the client can open all requested ports on the router, and
- the DNS service for your domain provides API access to edit DNS records.

The dynamic DNS service is configured with the `DYNAMIC_DNS_SERVICE` setting. The only supported
service is dnsimple.com; the DYNAMIC_DNS_SERVICE setting should be "dnsimple:<api_token>".

### Configuring the IP stack.

[todo]

- Reuse closed sockets
- Increase number of available sockets

### Running the server

To **run the pipe2me server in the foreground** change into the `./api` directory and run:

    foreman start

### Installing the server on Debian

To install the server on a debian system, use foreman to create the respective startup
script:

    foreman export initscript `pwd`/var/init.d --log `pwd`/var/log --app `whoami` --user `whoami`
    chmod 755 var/init.d/kinko/`whoami`

then copy the script into /etc/init.d and try to start the service:

    sudo cp var/init.d/`whoami` /etc/init.d
    sudo /etc/init.d/`whoami` start

Give it a second to start, then verify the status

    sudo /etc/init.d/`whoami` status

## pipe2me pod client

The pipe2me pod client lives in the client/ruby directory. In the future we will provide
additional client implementations, with the idea to replace the ruby client with something
else, probably a client written in `{ba}sh`, but this is still the future.

### Installation

    git clone ...
    cd api
    bundle install
    rake dependencies:install

### Configuring tunnels

To configure one or more tunnels run `pipe2me setup`. For example, the following
command will setup two tunnels, which will connect the outside world to local ports
20102 and 20103. The command responds with the FQDN of the tunnels.

    > pipe2me setup \
      --server pipe2me.server.name \
      --auth this-is-your-auth-token \
      --protocols https,http \
      --local-ports 20102,20103 \
    handsome-lemon-panda.test.pipe2.me

**Note:** The *auth-token* is the "currency" for the pipe2me server. How to obtain an auth-token
is outside the scope of this document. However, each auth-token allows to create a
single tunnel set with an upper limit on the number of tunnels.

You cannot request specific ports for your tunnels - they will be assigned
by the server. To find out more about your tunnels ask pipe2me

    > ./bin/pipe2me list handsome-lemon-panda.test.pipe2.me
    handsome-lemon-panda.test.pipe2.me
      path: /Users/eno/.pipe2me/tunnels/handsome-lemon-panda.test.pipe2.me
      ...
      urls: ["https://handsome-lemon-panda.test.pipe2.me:10001", "http://handsome-lemon-panda.test.pipe2.me:10002" ]
      ...

If you need these settings in an own command you can also load these into the environment
by running `. ./bin/pipe2me env handsome-lemon-panda.test.pipe2.me`

     > ./bin/pipe2me env handsome-lemon-panda.test.pipe2.me
    ...
    URLS_0=https://handsome-lemon-panda.test.pipe2.me:10001
    URLS_1=http://handsome-lemon-panda.test.pipe2.me:10002
    SERVER=http://test.pipe2.me:5000
    LOCAL_PORTS=20102,20103
    ...

## Testing tunnels

The pipe2me client helps you testing its tunnels. For this it
includes "echo"-servers for various protocols.

Assuming you set up tunnels `handsome-lemon-panda.test.pipe2.me` as above.
To run the tunnels in test mode you would run:

     > ./bin/pipe2me test

This starts all configured tunnels, and, where available, echo servers
on the specified local ports. In other words: in our example the command
above will run 2 connections to the tunnel server, and two echo servers
on localhost on the ports 20102 and 20103.

Use your browser or a command line http client to verify the local echo
servers. On port 20103 there should be a plain HTTP server running:

    # verify http server on port 20103
    ~ > curl http://localhost:20103/hello
    GET /hello

Port 20102 is configured to run a HTTPS server:

    # verify https server on port 20102. Note: curl's -k option disables
    # certificate verification.
    ~ > curl -k https://localhost:20102/hello


Now verify that the tunnels are working:

    # verify http server on port 10002
    ~ > curl http://handsome-lemon-panda.test.pipe2.me:10002/hello
    GET /hello

    # verify http server on port 10001. curl's -k option again disables
    # certificate verification.
    ~ > curl -k https://handsome-lemon-panda.test.pipe2.me:10001/hello
    GET /hello


This looks good. If you also want to verify the SSL certificates in use
see the chapter on "SSL"

# Start configured tunnels

## Hacking pipe2me

Please install the git trimWhitespace tool from [https://github.com/radiospiel/git-trim-whitespace](https://github.com/radiospiel/git-trim-whitespace).

### Running tests

The server comes with tests of its own. To run tests, you must, of course configure
and setup this package:

    # setup the server software
    bundle install
    bundle exec rake configure
    bundle exec rake install:dependencies

and then run the tests via rake:

    # run the server tests
    bundle exec rake test

You should also run the tests in the pipe2me-client package. See there for more details.


### Contributing

### Licensing

This software is released to you under the terms of the "GNU Affero General
Public License, version 3". (See the file COPYING.AGPL for details). That
means you are free to use, modify, ad redistribute the software **under
some conditions** that are laid out in the license. In short, you cannot
redistribute the software to someone else without giving them the same
rights to your modifications that we gave you to our codebase.
It also means that you cannot run a modified version of the pipe2me server
software without granting access to your modifications under the same terms
to the users of your service.

For more details see the file COPYING.APL, for a more thorough discussion compare [http://en.wikipedia.org/wiki/Affero_General_Public_License](http://en.wikipedia.org/wiki/Affero_General_Public_License).

This affects all code in this repository, with the notable exception of 3rd party code,
which could live in the `./vendor` directory.

#### Licensing issues with your contributions

However, licensing is a slightly different matter if you want to
contribute back to the project.

Because we don't know yet if we stick to the AGPL license for the future,
we need you to give us the right to relicense your modifications without having
to ask you. If you submit a pull request please make sure that you agree to that,
or else we cannot merge your changes back into the main codebase. This sounds
complicated, but really is not: you could (and probably should) license your
contributions under the terms of the MIT License.

If you feel unsure about this feel free to discuss this issue with us.

(c) The kinko team, 2014

### Supporting this project

> If you are hosting a domain, want to support this project, and decide to have a look
> at dnsimple.com, please use this link to sign up with dnsimple:
> [https://dnsimple.com/r/678c541be02c40](https://dnsimple.com/r/678c541be02c40)

> If you decide to run a pipe2me server with a proper intermediate certificate, consider
> getting one from ...

