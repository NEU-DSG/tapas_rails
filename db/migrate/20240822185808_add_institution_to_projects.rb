class AddInstitutionToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :institution, :string
  end
end
