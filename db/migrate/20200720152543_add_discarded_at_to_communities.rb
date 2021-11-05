class AddDiscardedAtToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :discarded_at, :datetime
    add_index :communities, :discarded_at
  end
end
