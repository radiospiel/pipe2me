class RededicateTunnelsToken < ActiveRecord::Migration
  def change
    # this is a *destructive* migration.
    execute "DELETE FROM tunnels"
    execute "DELETE FROM tunnel_ports"

    add_column :tunnels, :expires_at, :datetime
  end
end
