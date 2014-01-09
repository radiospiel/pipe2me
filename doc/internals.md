## pipe2me internals

pipe2me does three things:

1. it tunnels one or more (TCP) services on a specific machine (the *pod*)
   to the internet
1. it manages an individual FQDN for each set of services
1. it manages SSL certificates for each FQDN
1. it manages DNS for each FQDN so that the traffic goes the shortest possible way

The machines involved in this setup play three distinct roles:

1. A pipe2me **pod**: a machine, potentially behind a NAT-ting router or a firewall,
   which runs some services it wants to publish on the internet. This is a
   machine which currently must run either Linux or OSX.
1. A client: a computer which wants to consume services published by the **pod**.
   This could be an ordinary desktop or notebook PC, your mobile phone, etc.
1. A pipe2me **server**: the pipe2me server orchestrates the traffic between clients
   and pods.

The pipe2me software consists of two parts:

- the pipe2me server. For installation see [Server Installation](server).
- the pipe2me pod client: (`gem install pipe2me`). The pipe2me pod client
  contains a *pipe2me* binary, which should end up in your path.

Important note: the pipe2me client software is installed **on the pod**.
No software needs to be installed on the client.

### Service tunneling

Services are tunneled using ssh(1). *pipe2me* does not run ssh directly, but
uses autossh(1), which adds some logic to keep a ssh session running or
to restart it in case of trouble.

The pipe2me server run a designated sshd instance just for the purpose
of tunneling services on a specific control port. A pod can connect to
the server on that port, but cannot run any command - it can only
forward to a limited selection of ports.

To keep things secure the `pipe2me` client creates an ssh keypair
and registers the public key with the server.

### FQDN

When the client requests a subdomain with a specific number of ports the server generates
a unique FQDN, which it thens sends back to the client.

#### HTTP(S) forwarding

If a subdomain is registered to use one or more HTTP(S) connections, the server
supports automatic redirection based on the request.

If the server sees a request for `http://<subdomain>.pipe2me.domain`, it automatically
redirects to the first http service registered. If there is none, but a https
service on the same subdomain, it redirects to that service instead.

If the server sees a request for `https://<subdomain>.pipe2me.domain`, it automatically
redirects to the first https service registered. In no case does it redirect to
a http service on the same subdomain, as this would downgrade the connections
security.

All redirections are done via HTTP 301/302 status codes. In any case once the client
redirected it should no longer communicate with the `pipe2me` server. Note, however,
that in the https case the initial request is only secured against a wildcard certificate –
and all data with it is readable to the pipe2me server.

### SSL certificates for each FQDN

The pipe2me server manages SSL certificates for each subdomain. To receive a SSL
certificate the client creates a SSL key and a certificate signing request (CSR),
sends the CSR to the server, which then signs it and returns the signed certificate.

By default the server creates and manages a self-signed certificate for its own domain
name.

For improved security the server should be configured to use a real intermediate
certificate authority, with an ICA assigned by a "real" CA.

### DNS management

Traffic from a client to a pod could go on one of three ways:

1. direct connection (in the same network or in a bridged network setting)
1. tunneled connection via pipe2me server
1. indirect connection via router: the pod opens a port on the router, the client
   connects to that port on the router. This works if
   - the pod can open port(s) on the router for all services
   - the internet provider does not block traffic to those port(s)

pipe2me works in the second, or preferably third scenario. The pipe2me server observes
whether a connection to the router is possible, and if so, points the subdomain's
DNS entry directly to the router. If it is not or only partially (i.e. only for
some ports) possible, the DNS entry will be set to the pipe2me server instead.

These DNS entries have a very short time-to-live to make sure clients (usually)
connect to the right place, even if things have changed.

