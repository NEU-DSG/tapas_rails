class AddTagsToNewsItems < ActiveRecord::Migration[5.2]
  def up
    add_column :news_items, :tags, :string
  end

  def down
    remove_column :news_items, :tags
  end
end
