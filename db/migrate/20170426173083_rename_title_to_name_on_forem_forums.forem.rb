# This migration comes from forem (originally 20121203093719)
class RenameTitleToNameOnForemForums < ActiveRecord::Migration[5.2]
  def up
    rename_column :forem_forums, :title, :name
  end

  def down
    rename_column :forem_forums, :name, :title
  end
end
