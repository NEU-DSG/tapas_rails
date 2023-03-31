# This migration comes from forem (originally 20110221092741)
class CreateForemTopics < ActiveRecord::Migration[5.2]
  def change
    create_table :forem_topics do |t|
      t.integer :forum_id
      t.integer :user_id
      t.string :subject

      t.timestamps :null => true
    end
  end
end
