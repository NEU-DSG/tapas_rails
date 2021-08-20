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
    add_index :community_members, [:community_id, :user_id]
  end
end
