class CreateJoinTableCollectionCoreFile < ActiveRecord::Migration[5.2]
  def change
    create_join_table :collections, :core_files do |t|
      t.index [:collection_id, :core_file_id], unique: true
      t.index [:core_file_id, :collection_id], unique: true
    end
  end
end
