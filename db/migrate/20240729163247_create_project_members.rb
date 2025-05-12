class CreateProjectMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :project_members do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.boolean :is_project_depositor

      t.timestamps
    end

    add_index :project_members, [:project_id, :user_id], unique: true
  end
end
