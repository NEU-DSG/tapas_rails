class AddEncryptedApiKeyToUsers < ActiveRecord::Migration
  def up
    add_column :users, :encrypted_api_key, :string
  end

  def down 
    remove_column :users, :encrypted_api_key, :string 
  end
end
