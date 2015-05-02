class CreateTestStepResults < ActiveRecord::Migration
  def self.up
    execute 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'

    create_table :test_step_results do |t|
      t.belongs_to  :test_case_result, null: false
      t.belongs_to  :test_step,        null: false

      t.string      :result,         null: false

      #t.integer    :position
      t.datetime    :started_at
      t.integer     :duration

      t.timestamps
    end
    add_index :test_step_results, :test_case_result_id
    add_index :test_step_results, :test_step_id

    execute 'ALTER TABLE test_step_results  ALTER COLUMN id TYPE BIGINT'

    execute 'ALTER TABLE test_step_results ADD uuid UUID'
    execute 'ALTER TABLE test_step_results ALTER COLUMN uuid SET DEFAULT uuid_generate_v4()'
  end

  def self.down
    drop_table :test_step_results
    execute 'DROP EXTENSION "uuid-ossp";'
  end
end
