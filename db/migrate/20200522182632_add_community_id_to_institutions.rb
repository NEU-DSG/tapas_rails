class AddCommunityIdToInstitutions < ActiveRecord::Migration[5.2]
  def up
    change_column :institutions, :community_id, :bigint
    add_foreign_key :institutions, :communities
  end

  def down
    change_column :institutions, :community_id, :integer
    remove_foreign_key :institutions, :communities
  end
end
