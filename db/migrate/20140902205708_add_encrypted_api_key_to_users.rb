class AddEncryptedApiKeyToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :encrypted_api_key, :string
  end

  def down 
    remove_column :users, :encrypted_api_key, :string 
  end
end
