# Handles delegations to the properties datastream which are assumed
# to be universally useful. 
module CerberusCore::Concerns::PropertiesDatastreamDelegations
  extend ActiveSupport::Concern 

  included do 
    delegate :in_progress?, to: "properties"
    delegate :tag_as_in_progress, to: "properties"
    delegate :tag_as_completed, to: "properties" 
    delegate :canonize, to: "properties" 
    delegate :uncanonize, to: "properties" 
    delegate :canonical?, to: "properties" 
    has_attributes :depositor, :download_filename, 
                   datastream: "properties", 
                   multiple: false
    has_attributes :thumbnail_list, datastream: "properties", multiple: true

    # Ensures that the current depositor always has edit permissions, and that
    # people who are unflagged as the depositor (for whatever reason) lose their 
    # edit permissions.
    def depositor=(user_key)
      prior_depositor = self.properties.depositor.first

      if prior_depositor.present?  
        self.rightsMetadata.permissions({person: prior_depositor}, 'none') 
      end
        
      self.properties.depositor = user_key
      self.rightsMetadata.permissions({person: user_key}, 'edit') 
    end
  end
end