class AddStashIdAndStashOauthTokenAndStashOauthTokenSecretToUser < ActiveRecord::Migration
  def change
    add_column :users, :stash_id, :integer
    add_column :users, :stash_oauth_token, :string
    add_column :users, :stash_oauth_token_secret, :string

    add_index  :users, :stash_id, :unique => true
  end
end
