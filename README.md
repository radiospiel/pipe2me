# pipe2me

pipe2me lets you publish TCP services on the internet that are potentially running behind
a NATting proxy. Note that you need the pipe2me-client package to make sense of this.
`pipe2me-client` can be found here: [https://github.com/kinkome/pipe2me-client](https://github.com/kinkome/pipe2me-client)

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

Each pipe2me server instance manages a single domain (for example: `pipe2.me`) and its
subdomains (for example: `pink-unicorn.pipe2.me`). Each pod gets assigned a unique
subdomain.

## Installation

An installation guide is in [doc/install.md](https://github.com/kinkome/pipe2me/blob/master/doc/install.md).

## Running the server

The server is run via the monit(1) tool. To configure and run it, just run

<pre>
~/pipe2me$ <b>rake configure start</b>
</pre>

**Note:** There are also `rake stop` and `rake restart` commands.

## Running tests

The server comes with tests of its own. To run tests, you must, of course configure
and setup this package. After that run the tests via `rake`:

    # run the server tests
    bundle exec rake test

You should also run the tests in the pipe2me-client package. See there for more details.

## Licensing

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

## Hacking and Contributing

pipe2me and pipe2me-client are open sourced. Your contributions and pull requests are
welcome.

Please use the git trimWhitespace tool from [https://github.com/radiospiel/git-trim-whitespace](https://github.com/radiospiel/git-trim-whitespace). It helps **tremendously** with whitespace issues.

Please read the following note on licensing, though.

### Licensing issues with your contributions

Because we don't know yet if we stick to the AGPL license for the future,
we need you to give us the right to relicense your modifications without having
to ask you. If you submit a pull request please make sure that you agree to that,
or else we cannot merge your changes back into the main codebase. This sounds
complicated, but really is not: you could (and probably should) license your
contributions under the terms of the MIT License.

If you feel unsure about this feel free to discuss this issue with us.
## Supporting this project

> If you are hosting a domain, want to support this project, and decide to have a look
> at dnsimple.com, please use this link to sign up with dnsimple:
> [https://dnsimple.com/r/678c541be02c40](https://dnsimple.com/r/678c541be02c40)


Happy tunnelling!

(c) The kinko team, 2014

