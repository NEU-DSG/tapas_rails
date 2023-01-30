class AddDepositorIdToCoreFile < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :depositor_id, :integer, null: false
  end
end
