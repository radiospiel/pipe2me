class AddTunnelsStatus < ActiveRecord::Migration
  def change
    add_column :tunnels, :status, :string, :default => "", :null => false
    add_index :tunnels, :status
  end
end
