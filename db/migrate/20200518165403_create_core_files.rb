class CreateCoreFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :core_files do |t|
      t.string :title, null: false
      t.text :description
      t.timestamps
    end

    create_table :collections_core_files do |t|
      t.belongs_to :core_file
      t.belongs_to :collection
    end

    add_index :collections_core_files, [:collection_id, :core_file_id], unique: true
  end
end
