class AddImageUrlToImageFile < ActiveRecord::Migration[5.2]
  def change
    add_column :image_files, :image_url, :string
  end
end
