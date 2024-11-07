class CreateCollectionCoreFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :collection_core_files do |t|
      t.references :collection, foreign_key: true
      t.references :core_file, foreign_key: true

      t.timestamps
    end
  end
end
