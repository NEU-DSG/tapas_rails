class CreateJoinTableCommunitiesInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_join_table :communities, :institutions do |t|
      t.index [:community_id, :institution_id], unique: true, name: "index_communities_instutitions"
      t.index [:institution_id, :community_id], unique: true, name: "index_institutions_communities"
    end
  end
end
