class Collection < CerberusCore::BaseModels::Collection
  include Nid
  has_core_file_types  ["CoreFile"]
  has_collection_types ["Collection"]

  parent_community_relationship  :community 
  parent_collection_relationship :collection

  # Override default properties ds with our custom one.
  has_metadata :name => "mods", :type => ModsDatastream

  # Return the collection where we store TEI files that reference 
  # non-existant collections.  If it doesn't exist create it.
  def self.phantom_collection
    pid = Rails.configuration.phantom_collection_pid
    if Collection.exists?(pid)
      return Collection.find(pid)
    else 
      c = Collection.new(:pid => pid).tap do |c|
        c.mods.title     = "Orphaned TEI records." 
        c.depositor = "tapasrails@neu.edu"
      end

      c.save!
      return c
    end 
  end
end
