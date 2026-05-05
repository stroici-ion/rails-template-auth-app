class AddEmailConfirmationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :confirmed_email, :boolean, default: false
    add_column :users, :confirmation_token, :string
    
    add_index :users, :confirmation_token, unique: true
  end
end
