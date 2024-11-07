class CreateProjectCoreFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :project_core_files do |t|
      t.references :project, foreign_key: true
      t.references :core_file, foreign_key: true

      t.timestamps
    end

    add_index :project_core_files, [:project_id, :core_file_id], unique: true
  end
end
