class CreateRefreshTokens < ActiveRecord::Migration[8.1]
def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      
      t.string :crypted_token, null: false
      
      t.datetime :expires_at, null: false
      
      t.string :ip_address
      t.string :user_agent
      
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :refresh_tokens, :crypted_token, unique: true
  end
end
