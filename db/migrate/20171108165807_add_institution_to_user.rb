class AddInstitutionToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :institution, index: true
  end
end
