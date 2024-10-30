class CreateCoreFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :core_files do |t|
      t.string :title, null: false
      t.text :description
      t.timestamps
    end
  end
end
