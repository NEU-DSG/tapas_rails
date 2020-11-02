class CreateMenuLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :menu_links do |t|
      t.string :link_text, :null=>false
      t.string :link_href, :null=>false
      t.string :classes
      t.integer :link_order
      t.integer :parent_link_id
      t.string :menu_name
      t.timestamps
    end
  end
end
