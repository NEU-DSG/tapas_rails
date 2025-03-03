class AddTeiAuthorsToCoreFiles < ActiveRecord::Migration[5.2]
  def change
    add_column :core_files, :tei_authors, :text
  end
end
