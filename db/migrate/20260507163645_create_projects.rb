class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :color_code
      t.string :status
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
