class CreateSubdomains < ActiveRecord::Migration
  def change
    create_table :subdomains do |t|
      # an auth token for this subdomain
      t.string  :token

      # the hostname of the subdomain's host 
      t.string  :host
      
      # the name of the subdomain 
      t.string  :name

      # the scheme of the subdomain. This can be http or https
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
      t.index   :host
    end
  end
end
