class AddDiscardedAtToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :discarded_at, :datetime
    add_index :collections, :discarded_at
  end
end
