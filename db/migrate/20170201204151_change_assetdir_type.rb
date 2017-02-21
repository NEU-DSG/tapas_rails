class ChangeAssetdirType < ActiveRecord::Migration
  def up
    change_table :view_packages do |t|
      t.change :css_dir, :text
      t.change :js_dir, :text
    end
  end
  def down
    change_table :view_packages do |t|
      t.change :css_dir, :string
      t.change :js_dir, :string
    end
  end
end
