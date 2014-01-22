class AddTunnelsCheck < ActiveRecord::Migration
  def change
    create_table :tunnel_checks do |t|
      t.integer  :tunnel_id

      t.string   :source_ip
      t.string   :status

      t.datetime :created_at

      t.index :tunnel_id
      t.index :status
    end
  end
end
