class AddCommunityIdToInstitutions < ActiveRecord::Migration[5.2]
  def up
    add_column :institutions, :community_id, :bigint
    add_foreign_key :institutions, :communities
  end

  def down
    remove_column :institutions, :community_id
    remove_foreign_key :institutions, :communities
  end
end
