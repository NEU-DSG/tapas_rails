class AddUserTypeToUsersCoreFile < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files_users, :user_type, "enum('author', 'contributor')", default: "contributor", null: false
  end
end
