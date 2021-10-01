class RemoveCommunityIdFromInstitutions < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :institutions, :communities
    remove_column :institutions, :community_id
  end
end
