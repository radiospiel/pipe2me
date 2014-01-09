class CreateSubdomainsAndPorts < ActiveRecord::Migration
  def change
    create_table :subdomains do |t|
      # the subdomain token.
      t.string  :token

      # the hostname of the subdomain's endpoint.
      t.string  :endpoint

      # the full name of the domain.
      t.string  :fqdn

      # the private and public SSH key
      t.text    :ssh_public_key
      t.text    :ssh_private_key

      # openssl cert
      t.text    :openssl_certificate

      t.timestamps

      t.index :fqdn, unique: true
    end

    create_table :subdomain_ports do |t|
      t.integer  :port
      t.integer  :subdomain_id
      t.string   :protocol, default: "tcp"

      t.timestamps

      t.index :subdomain_id
      t.index :port, unique: true
    end
  end
end
