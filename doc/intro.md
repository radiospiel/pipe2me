
     > ./bin/pipe2me setup -s http://test.pipe2.me:5000 -a 123 -p https,http
    Generating a 1024 bit RSA private key
    ...........................................................................................++++++
    ......++++++
    writing new private key to '/Users/eno/.pipe2me/tunnels/handsome-lemon-panda.test.pipe2.me/openssl.privkey.pem'
    -----
    Updating: "handsome-lemon-panda.test.pipe2.me"
    handsome-lemon-panda.test.pipe2.me

In the example above two tunnels are set up for the name `handsome-lemon-panda.test.pipe2.me`.
To verify the settings run

     > ./bin/pipe2me list handsome-lemon-panda.test.pipe2.me
    handsome-lemon-panda.test.pipe2.me
      token: bm0r4rxwuvl64bkel54ou4r1t
      fqdn: handsome-lemon-panda.test.pipe2.me
      urls: ["https://handsome-lemon-panda.test.pipe2.me:10001", "http://handsome-lemon-panda.test.pipe2.me:10002"]
      tunnel: ssh://kinko@test.pipe2.me:4444
      server: http://test.pipe2.me:5000

Now start a local test server on both ports:

    PORT_HTTP=10001 PORT_HTTPS=10002 ./bin/shoreman

https://handsome-lemon-panda.test.pipe2.me:10001", "http://handsome-lemon-panda.test.pipe2.me:10002

- one for the protocol is set up


