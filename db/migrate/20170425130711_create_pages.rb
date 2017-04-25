class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title, :null=>false
      t.string :slug, :null=>false, :unique =>true
      t.text :content
    end
  end
end
