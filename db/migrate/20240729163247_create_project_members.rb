class CreateProjectMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :project_members do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role
      t.boolean :contributor?, default: true
      t.boolean :owner?, default: false
      t.boolean :depositor?, default: false

      t.timestamps
    end

    add_index :project_members, [:project_id, :user_id], unique: true
  end
end
