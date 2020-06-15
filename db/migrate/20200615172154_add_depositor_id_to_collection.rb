class AddDepositorIdToCollection < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :depositor_id, :integer, null: false
    add_index :collections, :depositor_id
  end
end
