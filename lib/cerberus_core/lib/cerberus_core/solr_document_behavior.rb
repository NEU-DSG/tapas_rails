module CerberusCore::SolrDocumentBehavior
  extend ActiveSupport::Concern
  include CerberusCore::Concerns::Traversals

  module ClassMethods
    def find_by_pid(pid) 
      r = ActiveFedora::SolrService.query("id:\"#{pid}\"")
      if r.first
        SolrDocument.new(r.first) 
      else
        msg = "Item with id #{pid} not found in Solr"
        raise CerberusCore::PidNotFoundInSolrError, msg
      end
    end
  end

  #---------------
  # General stuff
  #---------------

  def klass
    unique_read "active_fedora_model_ssi" 
  end

  def pid 
    unique_read "id" 
  end

  #-----------------------
  # Mods Datastream Stuff 
  #-----------------------

  def title
    unique_read "title_ssi"
  end

  def description
    unique_read "abstract_tesim"
  end

  def non_sort
    unique_read "title_info_non_sort_tesim"
  end

  def authorized_keywords 
    Array(self["subject_sim"]) 
  end

  def keywords 
    Array(self["subject_topic_tesim"]) 
  end

  def creators
    Array(self["creator_tesim"])
  end

  #-----------------------------
  # Properties Datastream Stuff
  #-----------------------------

  def depositor
    unique_read "depositor_tesim" 
  end

  def in_progress?
    unique_read("in_progress_tesim") == "true" 
  end

  def canonical? 
    unique_read("canonical_tesim") == "yes" 
  end

  def thumbnail_list 
    Array(self["thumbnail_list_tesim"]) 
  end

  def parent_id 
    unique_read "parent_id_tesim" 
  end

  #-------------------
  # Permissions Stuff
  #-------------------

  def read_groups
    Array(self[Ability.read_group_field])
  end

  def read_users
    Array(self[Ability.read_user_field])
  end

  def edit_groups
    Array(self[Ability.edit_group_field])
  end

  def edit_users
    Array(self[Ability.edit_user_field])
  end

  def mass_permissions
    if read_groups.include? 'public'
      'public'
    else
      'private'
    end
  end

  #---------
  # Helpers
  #---------

  def unique_read(field_name, default = '')
    val = Array(self[field_name]).first 
    val.present? ? val : default
  end
end
