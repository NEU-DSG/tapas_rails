class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.string :title, :null=>false
      t.string :slug, :null=>false, :unique =>true
      t.text :content
    end
  end
end
