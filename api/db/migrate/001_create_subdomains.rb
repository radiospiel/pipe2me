class CreateSubdomains < ActiveRecord::Migration
  def change
    create_table :subdomains do |t|
      # an auth token for this subdomain
      t.string  :token

      # the hostname of the subdomain's endpoint.
      t.string  :endpoint

      # the full name of the domain.
      t.string  :name

      # the scheme of the subdomain at port :port. This can be http
      # or https, and is used to verify whether a client is accessible.
      t.string  :scheme, default: "http"

      # the first port number of the subdomain
      t.integer :port

      # the private and public SSH key
      t.text    :ssh_public_key
      t.text    :ssh_private_key

      # subdomain time stamps
      t.timestamps

      t.index   :token
      t.index   :port
    end
  end
end
