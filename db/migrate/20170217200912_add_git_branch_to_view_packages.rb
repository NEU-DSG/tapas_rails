class AddGitBranchToViewPackages < ActiveRecord::Migration[5.2]
  def up
    add_column :view_packages, :git_branch, :string
  end

  def down
    remove_column :view_packages, :git_branch
  end
end
