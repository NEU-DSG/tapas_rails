class MenuItem < ActiveRecord::Base
  attr_accessible :link_text, :link_href, :classes, :link_order, :parent_link_id, :menu_name if Rails::VERSION::MAJOR < 4
  validates_presence_of :link_text, :link_href, :link_order, :menu_name


end
