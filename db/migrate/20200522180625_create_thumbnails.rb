class CreateThumbnails < ActiveRecord::Migration[5.2]
  def change
    create_table :thumbnails do |t|
      t.string :url, null: false
      t.text :caption
      t.references :owner, polymorphic: true

      t.timestamps
    end
  end
end
