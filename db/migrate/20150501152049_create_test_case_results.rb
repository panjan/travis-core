class CreateTestCaseResults < ActiveRecord::Migration
  def change
    create_table :test_case_results do |t|
      t.integer :position
      t.belongs_to :job,          null: false
      t.belongs_to :test_case,    null: false

      t.integer :duration
      t.integer :failed_count
      t.integer :success_count

      t.timestamps
    end
    add_index :test_case_results, :job_id
    add_index :test_case_results, :test_case_id
  end
end
