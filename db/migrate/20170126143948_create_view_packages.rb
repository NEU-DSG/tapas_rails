class CreateViewPackages < ActiveRecord::Migration
  def change
    create_table :view_packages do |t|
      t.string :human_name
      t.string :machine_name
      t.text :description
      t.text :file_type
      t.string :css_dir
      t.string :js_dir
      t.text :parameters
      t.text :run_process

      t.timestamps
    end
  end
end
