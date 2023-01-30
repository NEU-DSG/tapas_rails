class AddDiscardedAtToCoreFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :discarded_at, :datetime
    add_index :core_files, :discarded_at
  end
end
