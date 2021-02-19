class ChangeDataTypeForPublish < ActiveRecord::Migration[5.2]
  def self.up
    NewsItem.connection.execute("UPDATE news_items SET publish = CASE publish WHEN 'true' THEN 1 END")
    Page.connection.execute("UPDATE pages SET publish = CASE publish WHEN 'true' THEN 1 END")

    change_table :news_items do |t|
      t.change :publish, :boolean
    end
    change_table :pages do |t|
      t.change :publish, :boolean
    end
  end
  def self.down
    NewsItem.connection.execute("UPDATE news_items SET publish = CASE publish WHEN 1 THEN 'true' END")
    Page.connection.execute("UPDATE pages SET publish = CASE publish WHEN 1 THEN 'true' END")
    change_table :news_items do |t|
      t.change :publish, :string
    end
    change_table :pages do |t|
      t.change :publish, :string
    end
  end
end
