class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.string :status
      t.datetime :start_date
      t.datetime :due_date
      t.references :project, null: false, foreign_key: true
      t.integer :parent_id

      t.timestamps
    end
    add_index :tasks, :parent_id
  end
end
