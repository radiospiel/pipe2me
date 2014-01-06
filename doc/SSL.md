## SSL

The pipe2me server maintains individual certificates for each subdomain.
This means that you can trust the authenticity of each connection to your
pod services, if those are configured to use the certificate.

[TODO] Should the client enable OpenSSL connections, i.e. secure connections to
non-SSL-enabled services on the pod?

For this the server runs a CA to sign certificate requests it receives
from the client. As each subdomain is identified by a cryptograpically
strong token the server makes sure that a signing request is accepted
only from the correct client.

By default the pipe2me server creates a CA with a self-signed root
certificate.

## Configuring an intermediate CA

[TODO]

## Verifying tunnels' certificates

The pipe2me client helps you testing its tunnels. For this it
includes "echo"-servers for various protocols.

Assuming you set up a tunnel `handsome-lemon-panda.test.pipe2.me`
with two ports:

    > pipe2me setup \
        --server pipe2me.server.name \
        --auth this-is-your-auth-token \
        --protocols https,http \
        --local-ports 20102,20103
        handsome-lemon-panda.test.pipe2.me

Verify the service URLs with

    > pipe2me env handsome-lemon-panda* | grep URL
    URLS_0=https://handsome-lemon-panda.test.pipe2.me:10001
    URLS_1=http://handsome-lemon-panda.test.pipe2.me:10002

Now start these tunnels in test mode:

     > ./bin/pipe2me test

This starts an HTTPS server on https://handsome-lemon-panda.test.pipe2.me:10001,
which is connected to a HTTPS server on localhost:20102. Lets verify the client
certificate on localhost first:

    # inspect the https server's certificate.
    ~ > openssl s_client -connect localhost:20102 < /dev/null 2>/dev/null \
        | openssl x509 -in /dev/stdin  -text  \
        | grep Subject.*CN
            Subject: C=de, ST=ne, L=Berlin, O=kinko, CN=handsome-lemon-panda.test.pipe2.me

and then on the tunnel:

    # inspect the https server's certificate.
    ~ > openssl s_client -connect handsome-lemon-panda.test.pipe2.me:10001 < /dev/null 2>/dev/null \
       | openssl x509 -in /dev/stdin  -text \
       | grep Subject.*CN
          Subject: C=de, ST=ne, L=Berlin, O=kinko, CN=handsome-lemon-panda.test.pipe2.me

Both are written for the `handsome-lemon-panda.test.pipe2.me` name. And it is,
in fact, the same certificate:

    ~ > openssl s_client -connect localhost:20102 < /dev/null 2>/dev/null \
        | openssl x509 -in /dev/stdin  -out /dev/null -fingerprint
    SHA1 Fingerprint=57:AA:FB:D9:DF:9A:A5:D7:36:B1:F9:28:EE:28:52:9C:FD:E5:CE:40
    ~ > openssl s_client -connect handsome-lemon-panda.test.pipe2.me:10001 < /dev/null 2>/dev/null \
       | openssl x509 -in /dev/stdin  -out /dev/null -fingerprint
    SHA1 Fingerprint=57:AA:FB:D9:DF:9A:A5:D7:36:B1:F9:28:EE:28:52:9C:FD:E5:CE:40

This is hardly surprising, as it is the same server answering the requests - the
server on your local machine.

## Trusting a self-signed certificates

By default the server creates a self-signed certificate which is used to sign
each individual pod certificate. This means that a client cannot verify it
using the "official" certificate chain built into his or her browser.

Unless you decide to go with a proper intermediate certificate from a proper
CA you also might decide to install the self-signed certificate. You find the
certificate

In that case you would use the downloaded certificate from the server, You
find it at

    curl http://test.pipe2.me:/hello

The server publishes the certificate used for signing on the "/cacert" URL.
The certificate is downloaded from the server during the configuration step,
and it can be found in the ${TUNNEL_PATH}/cacert, where TUNNEL_PATH is a
result from the "pipe2me env" command:

    > ./bin/pipe2me env handsome-lemon-panda.test.pipe2.me
    TUNNEL_PATH=/Users/eno/.pipe2me/tunnels/handsome-lemon-panda.test.pipe2.me
    SERVER=http://test.pipe2.me:5000
    LOCAL_PORTS=20102,20103
    ...

    > cat /Users/eno/.pipe2me/tunnels/handsome-lemon-panda.test.pipe2.me/cacert
    -----BEGIN CERTIFICATE-----
    MIIDXzCCAkegAwIBAgIJAMOcSUM68l27MA0GCSqGSIb3DQEBBQUAMEYxCzAJBgNV
    BAYTAkRFMQ8wDQYDVQQIDAZCZXJsaW4xDzANBgNVBAcMBkJlcmxpbjEVMBMGA1UE
    AwwMcGlwZTJtZS1yb290MB4XDTE0MDEwNTE3NDQ1NVoXDTMzMTIzMTE3NDQ1NVow
    ....

**Note:** you could also run

    > eval `./bin/pipe2me env handsome-lemon-panda.test.pipe2.me`
    > cat $TUNNEL_PATH/cacert
    ...

Now you can use that certificate with your client. The following is an example
for the `curl` command line client:

    > curl --cacert $TUNNEL_PATH/cacert https://handsome-lemon-panda.test.pipe2.me:10001/hello
    GET /hello

which works fine, and this time without skipping certificate validation.

