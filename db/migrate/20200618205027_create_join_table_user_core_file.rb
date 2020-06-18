class CreateJoinTableUserCoreFile < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :core_files do |t|
      t.index [:user_id, :core_file_id], unique: true
      t.index [:core_file_id, :user_id], unique: true
    end
  end
end
