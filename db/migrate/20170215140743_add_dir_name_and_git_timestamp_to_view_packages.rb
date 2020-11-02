class AddDirNameAndGitTimestampToViewPackages < ActiveRecord::Migration[5.2]
  def up
    add_column :view_packages, :dir_name, :string
    add_column :view_packages, :git_timestamp, :datetime
  end

  def down
    remove_column :view_packages, :dir_name
    remove_column :view_packages, :git_timestamp
  end
end
