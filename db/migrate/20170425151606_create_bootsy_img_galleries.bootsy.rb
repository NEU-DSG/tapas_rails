# This migration comes from bootsy (originally 20120628124845)
class CreateBootsyImgGalleries < ActiveRecord::Migration[5.2]
  def change
    create_table :bootsy_img_galleries do |t|
      t.references :bootsy_resource, polymorphic: true
      t.timestamps
    end
  end
end
