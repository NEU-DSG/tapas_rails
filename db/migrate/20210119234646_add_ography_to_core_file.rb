class AddOgraphyToCoreFile < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :ography, :string
  end
end
