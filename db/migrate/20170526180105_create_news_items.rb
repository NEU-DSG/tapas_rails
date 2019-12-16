class CreateNewsItems < ActiveRecord::Migration
  def change
    create_table :news_items do |t|
      t.string :author
      t.string :publish
      t.string :title, :null=>false
      t.string :slug, :null=>false, :unique =>true
      t.text :content
      t.timestamps
    end
  end
end
