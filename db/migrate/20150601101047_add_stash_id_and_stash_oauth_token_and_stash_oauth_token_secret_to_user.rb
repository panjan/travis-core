class AddStashIdAndStashOauthTokenAndStashOauthTokenSecretToUser < ActiveRecord::Migration
  def change
    add_column :users, :stash_id, :integer
    add_index :users, :stash_id, :unique => true
    add_column :users, :stash_oauth_token, :string
    add_column :users, :stash_oauth_token_secret, :string
  end
end
