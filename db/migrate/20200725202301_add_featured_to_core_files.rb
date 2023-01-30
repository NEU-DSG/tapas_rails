class AddFeaturedToCoreFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :featured, :boolean
  end
end
