class AddMessageColumnToBuilds < ActiveRecord::Migration
  def up
    add_column :builds, :message, :text
  end

  def down
    remove_column :builds, :message
  end
end
