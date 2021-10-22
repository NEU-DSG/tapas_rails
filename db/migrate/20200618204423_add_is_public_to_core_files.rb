class AddIsPublicToCoreFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :is_public, :boolean, default: true
  end
end
