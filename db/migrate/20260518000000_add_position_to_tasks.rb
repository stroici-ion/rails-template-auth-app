class AddPositionToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :position, :integer
    add_index :tasks, [:project_id, :position]
  end
end
