class RenameCommunityCollectionsToProjectCollections < ActiveRecord::Migration[5.2]
  def change
    rename_table :community_collections, :project_collections

    add_index :project_collections, [:collection_id, :project_id], name: 'index_project_collections_on_collection_id_and_project_id'
  end
end
