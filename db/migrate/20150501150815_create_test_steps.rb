class CreateTestSteps < ActiveRecord::Migration
  def change
    create_table :test_steps do |t|
      t.string :name,           null: false
      t.belongs_to :test_case,  null: false

      t.timestamps
    end
    add_index :test_steps, :test_case_id
  end
end
