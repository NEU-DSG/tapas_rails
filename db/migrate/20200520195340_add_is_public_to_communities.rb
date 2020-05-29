class AddIsPublicToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :is_public, :boolean, default: true
  end
end
