class AddTeiContributorsToCoreFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :tei_contributors, :text
  end
end
