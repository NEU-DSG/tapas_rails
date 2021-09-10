class CreateCoreFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :core_files do |t|
      t.string :title, null: false
      t.text :description
      t.timestamps
    end

    create_table :core_files_collections do |t|
      t.belongs_to :core_file
      t.belongs_to :collection
    end

    add_index :core_files_collections, [:core_file_id, :collection_id], unique: true
  end
end
