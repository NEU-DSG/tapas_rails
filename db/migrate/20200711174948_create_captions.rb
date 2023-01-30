class CreateCaptions < ActiveRecord::Migration[5.2]
  def change
    create_table :captions do |t|
      t.references :active_storage_attachment, foreign_key: true
    end
  end
end
