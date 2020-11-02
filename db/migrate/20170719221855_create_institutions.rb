class CreateInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :institutions do |t|
      t.string :name, :null=>false
      t.string :description
      t.string :image
      t.string :address
      t.string :latitude
      t.string :longitude
      t.string :url
      t.timestamps
    end
  end
end
