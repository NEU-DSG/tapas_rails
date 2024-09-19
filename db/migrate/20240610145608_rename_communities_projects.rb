class RenameCommunitiesProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :is_public, :boolean, default: true

    rename_table :communities, :projects
  end
end
