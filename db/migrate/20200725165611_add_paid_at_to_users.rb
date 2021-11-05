class AddPaidAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :paid_at, :datetime
  end
end
