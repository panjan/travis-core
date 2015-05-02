class CreateTestStepData < ActiveRecord::Migration
  def change
    create_table :test_step_data do |t|
      t.text :message
      t.text :stdout
      t.text :stderr

      #t.boolean :crashed, default: false, null: false
      t.belongs_to :test_step_result,   null: false

      t.timestamps
    end
    add_index :test_step_data, :test_step_result_id
  end
end
