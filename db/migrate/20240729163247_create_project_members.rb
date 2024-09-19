class CreateProjectMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :project_members do |t|
      t.belongs_to :project
      t.belongs_to :user
      t.string :role, default: 'contributor'

      t.timestamps
    end
  end
end
