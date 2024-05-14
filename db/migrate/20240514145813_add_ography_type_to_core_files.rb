class AddOgraphyTypeToCoreFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :ography_type, :string, array:true
  end
end
