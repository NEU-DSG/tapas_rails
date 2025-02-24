class CreateJoinTableProjectCoreFile < ActiveRecord::Migration[5.2]
  def change
    create_join_table :projects, :core_files do |t|
      t.index [:project_id, :core_file_id], unique: true
      t.index [:core_file_id, :project_id], unique: true
    end
  end
end
