class CreateExecutionLogs < ActiveRecord::Migration
  def up
    create_table :execution_logs do |t|
      t.references  :build, index: true, foreign_key: true

      t.integer :position
      t.datetime :timestamp
      t.text :message
    end
  end

  def down
    drop_table :execution_logs
  end
end
