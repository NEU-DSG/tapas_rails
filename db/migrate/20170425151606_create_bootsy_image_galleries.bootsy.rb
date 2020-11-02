# This migration comes from bootsy (originally 20120628124845)
class CreateBootsyImageGalleries < ActiveRecord::Migration[5.2]
  def change
    create_table :bootsy_image_galleries do |t|
      t.references :bootsy_resource, polymorphic: true, index: { name: "index_bootsy_image_galleries_on_bootsy_resource_type_and_id" }
      t.timestamps
    end
  end
end
