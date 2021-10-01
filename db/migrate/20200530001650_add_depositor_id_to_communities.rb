class AddDepositorIdToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :depositor_id, :integer, null: false
    add_index :communities, :depositor_id
  end
end
