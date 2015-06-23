class Collection < CerberusCore::BaseModels::Collection
  include Did
  include OGReference
  include DrupalAccess

  after_save :update_core_files

  has_core_file_types  ["CoreFile"]
  has_collection_types ["Collection"]

  has_many :personographies, :property => :is_personography_for, 
    :class_name => "CoreFile"
  has_many :orgographies, :property => :is_orgography_for, 
    :class_name => "CoreFile"
  has_many :bibliographies, :property => :is_bibliography_for, 
    :class_name => "CoreFile"
  has_many :otherographies, :property => :is_otherography_for, 
    :class_name => "CoreFile"
  has_many :odd_files, :property => :is_odd_file_for, 
    :class_name => "CoreFile"

  parent_community_relationship  :community 
  parent_collection_relationship :collection

  has_metadata :name => "mods", :type => ModsDatastream
  has_metadata :name => "properties", :type => PropertiesDatastream

  # Return the collection where we store TEI files that reference 
  # non-existant collections.  If it doesn't exist create it.
  def self.phantom_collection
    pid = Rails.configuration.phantom_collection_pid
    if Collection.exists?(pid)
      return Collection.find(pid)
    else 
      c = Collection.new(:pid => pid).tap do |c|
        c.mods.title = "Orphaned TEI records." 
        c.depositor = "tapasrails@neu.edu"
      end

      c.save!
      return c
    end 
  end

  def drupal_access=(level)
    properties.drupal_access = level 
    @drupal_access_changed = true 
  end

  private 

    def update_core_files
      return true unless @drupal_access_changed 

      if drupal_access == 'private' 

      elsif drupal_access == 'public' 
        self.descendent_records(:raw).each do |record| 
          unless record['drupal_access_ssim'] == 'public'
            core_file = CoreFile.find(record['id'])
            core_file.drupal_access = 'public' 
            core_file.save! 
          end
        end
      end
    end
end
