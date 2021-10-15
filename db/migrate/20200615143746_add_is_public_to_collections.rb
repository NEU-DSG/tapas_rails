class AddIsPublicToCollections < ActiveRecord::Migration[5.2]
  def change
    add_column :collections, :is_public, :boolean
  end
end
