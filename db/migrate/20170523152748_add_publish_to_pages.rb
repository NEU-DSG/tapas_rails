class AddPublishToPages < ActiveRecord::Migration[5.2]
  def up
    add_column :pages, :publish, :string
  end

  def down
    remove_column :pages, :publish
  end
end
