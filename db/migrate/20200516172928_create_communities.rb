class CreateCommunities < ActiveRecord::Migration[5.2]
  def change
    create_table :communities do |t|
      t.string :title, null: false
      t.text :description
      t.timestamps
    end

    create_table :community_members do |t|
      t.belongs_to :community
      t.belongs_to :user
    end

    add_column :community_members, :member_type, "enum('member', 'editor', 'admin')", default: "member"
    add_index :community_members, [:community_id, :user_id], unique: true

    create_table :community_communities do |t|
      t.belongs_to :community
      t.integer :parent_community_id, null: false
    end

    add_index :community_communities, [:community_id, :parent_community_id], unique: true, name: 'index_community_parent'
  end
end
