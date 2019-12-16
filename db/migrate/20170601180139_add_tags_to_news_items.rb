class AddTagsToNewsItems < ActiveRecord::Migration
  def up
    add_column :news_items, :tags, :string
  end

  def down
    remove_column :news_items, :tags
  end
end
