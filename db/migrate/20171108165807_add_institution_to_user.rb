class AddInstitutionToUser < ActiveRecord::Migration
  def change
    add_reference :users, :institution, index: true
  end
end
