class CreateImageFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :image_files do |t|
      t.string  :title, null: false
      t.integer :depositor_id, null: false
      t.text :description
      t.string :file_format
      t.references :imageable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
