class CreateCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :collections do |t|
      t.string :title, null: false
      t.text :description

      t.timestamps
    end

    create_table :community_collections do |t|
      t.references :collection, foreign_key: true
      t.references :community, foreign_key: true

      t.timestamps
    end
  end
end
