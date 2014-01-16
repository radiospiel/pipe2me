class RenameSubdomainsToTunnels < ActiveRecord::Migration
  def change
    rename_table :subdomains, :tunnels
    rename_column :subdomain_ports, :subdomain_id, :tunnel_id
    rename_table :subdomain_ports, :tunnel_ports
  end
end
