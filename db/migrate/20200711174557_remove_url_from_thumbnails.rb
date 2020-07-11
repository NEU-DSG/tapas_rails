class RemoveUrlFromThumbnails < ActiveRecord::Migration[5.2]
  def change
    remove_column :thumbnails, :url
  end
end
