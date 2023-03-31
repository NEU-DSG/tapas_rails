# This migration comes from forem (originally 20120222155549)
class CreateForemGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :forem_groups do |t|
      t.string :name
    end

    add_index :forem_groups, :name
  end
end
