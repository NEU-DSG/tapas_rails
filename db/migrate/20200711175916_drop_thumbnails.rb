class DropThumbnails < ActiveRecord::Migration[5.2]
  def change
    drop_table :thumbnails
  end
end
