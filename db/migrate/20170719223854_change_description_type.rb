class ChangeDescriptionType < ActiveRecord::Migration
  def up
    change_table :institutions do |t|
      t.change :description, :text
    end
  end

  def down
    change_table :institutions do |t|
      t.change :description, :string
    end
  end
end
