class AddSubmenuToPages < ActiveRecord::Migration[5.2]
  def up
    add_column :pages, :submenu, :string
  end

  def down
    remove_column :pages, :submenu
  end
end
