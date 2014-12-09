module DrupalAccess
  extend ActiveSupport::Concern

  included do 
    has_attributes :drupal_access, datastream: "properties", multiple: false
  end
end
