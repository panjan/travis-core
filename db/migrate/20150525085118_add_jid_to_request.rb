class AddJidToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :jid, :string
  end
end
