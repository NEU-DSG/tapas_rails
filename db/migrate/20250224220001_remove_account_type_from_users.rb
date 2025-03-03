class RemoveAccountTypeFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :account_type
  end
end
