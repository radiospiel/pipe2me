class RemoveSshPrivKey < ActiveRecord::Migration
  def up
    remove_column :subdomains, :ssh_private_key
  end

  def down
    add_column :subdomains, :ssh_private_key, :string
  end
end
