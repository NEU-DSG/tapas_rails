class CreateCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :collections do |t|
      t.string :title, null: false
      t.text :description

      t.timestamps
    end

    create_table :community_collections do |t|
      t.belongs_to :collection
      t.belongs_to :community
    end

    add_index :community_collections, [:collection_id, :community_id], unique: true

    create_table :collection_collections do |t|
      t.belongs_to :collection
      t.integer :parent_collection_id, null: false
    end

    add_index :collection_collections, [:collection_id, :parent_collection_id], unique: true, name: "index_collections_parent"
  end
end
