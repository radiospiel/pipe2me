class AddSubdomainCertificate < ActiveRecord::Migration
  def change
    add_column :subdomains, :openssl_certificate, :text
  end
end
