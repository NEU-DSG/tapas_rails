class RemovePaidAtFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :paid_at
  end
end
