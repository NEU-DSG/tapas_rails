module CerberusCore::Datastreams
  # Catch all datastream for information that didn't have another home.
  # Useful for implementing persistence of information that isn't interesting
  # from an archival/curation point of view, for example an array of urls pointing
  # at the thumbnail file locations for this object, which is handy when reading 
  # from solr responses.
  class PropertiesDatastream < ActiveFedora::OmDatastream
    set_terminology do |t|
      t.root(:path=>"fields" )
      # Note that trying to delegate #parent_id to any object which defines 
      # a relationship referred to as #parent will cause a collision.  Instead of 
      # writing/to reading from the properties datastream it'll be trying to use 
      # the *_id helpers provided by ActiveFedora.
      t.parent_id :index_as=>[:stored_searchable]
      # This is where we put the user id of the object depositor -- impacts permissions/access controls
      t.depositor :index_as=>[:stored_searchable]
      t.thumbnail_list :index_as=>[:stored_searchable]
      t.canonical  :index_as=>[:stored_searchable]
      t.in_progress path: 'inProgress', :index_as=>[:stored_searchable]
      t.download_filename index_as: [:symbol]
    end

    def self.xml_template
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.fields
      end
      builder.doc
    end

    def prefix
      ""
    end

    # Checks if the Fedora object is in progress, indicating
    # that the system must do additional work before it can be 
    # considered 'complete'.  Typically, this additional work involves
    # content objects pointing at a core record that should be created
    # before the object is displayed to the world.
    def in_progress?
      return ! self.in_progress.empty?
    end

    # Tag this fedora object as in progress.  See #in_progress?
    def tag_as_in_progress
      self.in_progress = 'true'
    end

    # Tag this fedora object as completed.  See #in_progress?.
    def tag_as_completed
      self.in_progress = []
    end

    # Indicates this object is canon.  See #canonical? 
    def canonize
      self.canonical = 'yes'
    end

    # Indicates this object is no longer canon.  See #canonical?
    def uncanonize
      self.canonical = ''
    end

    # Check that this (typically content bearing) Fedora object is the chief 
    # object associated with some other object (typically a core record).  For
    # example, a core record with an associated master image object and derivatives
    # generated from that master image would tag the master image as the canonical 
    # record.
    def canonical?
      return self.canonical.first == 'yes'
    end
  end
end