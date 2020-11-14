class AddUsernameToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :username, :string, unique: true
    add_index :users, :username

    User.all.each do |u|
      begin
        # "My Name" -> "MyName"
        username = User.find_unique_username(
          (u.name || "anonymous").parameterize(separator: '', preserve_case: true)
        )
        u.update(username: username)
      rescue => e
        puts "--- Could not update user #{u.id}! --- \n---\n --- Reason: #{e} ---"
      end
    end
  end

  def down
    remove_column :users, :username
  end
end
