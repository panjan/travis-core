class AddNameAndStoppedByIdAndStoppedByTypeAndBuildInfoAndProtonIdToBuilds < ActiveRecord::Migration
  def up
    add_column :builds, :name, :string                      # config.name
    add_column :builds, :stopped_by_id,   :integer          # polymorphic
    add_column :builds, :stopped_by_type, :string           # polymorphic
    add_column :builds, :build_info,    :string             # config.build
    add_column :builds, :proton_id,     :integer, limit: 8  # config.runtimeConfig[:protonId]
    execute "UPDATE builds SET proton_id=(config#>'{runtimeConfig,protionId}')::text::int8;"
    execute "UPDATE builds SET name=config->'name';"
    execute "UPDATE builds SET build_info=config->'build';"
  end

  def down
    remove_column :builds, :name
    remove_column :builds, :stopped_by_id
    remove_column :builds, :stopped_by_type
    remove_column :builds, :build_info
    remove_column :builds, :proton_id
  end
end
