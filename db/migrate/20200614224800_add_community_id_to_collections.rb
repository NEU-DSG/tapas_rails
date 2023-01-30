class AddCommunityIdToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :community_id, :integer, null: false, unique: true
  end
end
