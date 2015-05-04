class AddProviderToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :provider, :string, allow_null: false, default: 'github'
  end
end
