class AddTimestampsToPages < ActiveRecord::Migration[5.2]
  def change
    add_timestamps :pages
  end
end
