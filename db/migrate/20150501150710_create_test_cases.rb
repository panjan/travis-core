class CreateTestCases < ActiveRecord::Migration
  def change
    create_table :test_cases do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
