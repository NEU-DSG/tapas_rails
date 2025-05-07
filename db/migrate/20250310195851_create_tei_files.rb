class CreateTeiFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :tei_files do |t|
      t.belongs_to :core_file, index: true
      t.string :name, null: false
      t.string :url, null: false
      t.string :data, null: false

      t.timestamps
    end
  end
end
