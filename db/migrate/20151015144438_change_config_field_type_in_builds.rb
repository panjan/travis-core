class ChangeConfigFieldTypeInBuilds < ActiveRecord::Migration
  def up
    require 'travis'
    require 'travis/model'
    Build.select('id, state, config as raw_config').all.each do |b|
      config = YAML.load(b.raw_config)
      b.update_column(:config, config.to_json)
    end
    # ..or for postgres 9.4 use TYPE JSONB USING config::text::jsonb;
    execute "ALTER TABLE builds ALTER COLUMN config TYPE JSON USING config::JSON;"
  end

  def down
    execute "ALTER TABLE builds ALTER COLUMN config TYPE text;"
    Build.select('id, state, config as raw_config').all.each do |b|
      config = JSON.load(b.raw_config)
      b.update_column(:config, YAML.dump(config))
    end

  end
end
