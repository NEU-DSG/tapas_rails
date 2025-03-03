class RenameCommunityIdToProjectId < ActiveRecord::Migration[5.2]
  def change
    rename_column :collections, :community_id, :project_id

    # rename_column :community_members, :community_id, :project_id

    rename_column :community_collections, :community_id, :project_id
  end
end
