class FixAssetdirNames < ActiveRecord::Migration[5.2]
  def up
    rename_column :view_packages, :css_dir, :css_files
    rename_column :view_packages, :js_dir, :js_files
  end
  def down
    rename_column :view_packages, :css_files, :css_dir
    rename_column :view_packages, :js_files, :js_dir
  end
end
