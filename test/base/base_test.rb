class BaseTest < Pipe2me::TestCase
  def test_setup
    # -- Public interface ---------------------------------------------

    # setup returns the domain name
    lines = pipe2me "setup",  protocols: "http",
                              server: "http://localhost:4000",
                              auth: "pipe2me-test-auth"

    lines = lines.split("\n")
    assert_equal(1, lines.length)
    tunnel = lines.first
    assert File.fnmatch("*.pipe2.dev", tunnel)

    # -- Implementation details ---------------------------------------

    # the following files must exist
    assert File.exist?("pipe2me-config/openssl/openssl.conf")

    tunnels = Dir.glob("pipe2me-config/tunnels/*")
    assert_equal(1, tunnels.length)

    assert_equal("pipe2me-config/tunnels/#{tunnel}", tunnels.first)

    assert File.exist?("pipe2me-config/tunnels/#{tunnel}/id_rsa")
    assert File.exist?("pipe2me-config/tunnels/#{tunnel}/id_rsa.pub")
    assert File.exist?("pipe2me-config/tunnels/#{tunnel}/info.inc")
    assert File.exist?("pipe2me-config/tunnels/#{tunnel}/local.inc")
    assert File.exist?("pipe2me-config/tunnels/#{tunnel}/openssl.csr")
    assert File.exist?("pipe2me-config/tunnels/#{tunnel}/openssl.pem")
    assert File.exist?("pipe2me-config/tunnels/#{tunnel}/openssl.privkey.pem")

    # -- Public interface ---------------------------------------------

    # the listing contains one entry
    assert_equal "#{tunnel}\n", pipe2me("ls")
  end
end
