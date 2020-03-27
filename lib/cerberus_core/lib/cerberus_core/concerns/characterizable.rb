# Implements delegations for/basic characterization method to use with
# objects that have a content datastream.  Since characterization is slow
# and will typically need to be implemented in a job that runs outside of
# the response cycle no default callback is created. 
module CerberusCore::Concerns::Characterizable
  extend ActiveSupport::Concern 

  included do 
    delegate :mime_type, :to => :characterization, :unique => true
    has_attributes :format_label, :file_size, :last_modified,
                   :filename, :original_checksum, :rights_basis,
                   :copyright_basis, :copyright_note,
                   :well_formed, :valid, :status_message,
                   :file_title, :file_author, :page_count,
                   :file_language, :word_count, :character_count,
                   :paragraph_count, :line_count, :table_count,
                   :graphics_count, :byte_order, :compression,
                   :width, :height, :color_space, :profile_name,
                   :profile_version, :orientation, :color_map,
                   :image_producer, :capture_device,
                   :scanning_software, :exif_version,
                   :gps_timestamp, :latitude, :longitude,
                   :character_set, :markup_basis,
                   :markup_language, :duration, :bit_depth,
                   :sample_rate, :channels, :data_format, :offset,
                   datastream: "characterization", 
                   multiple: true
  end

  # Uses the extract_metadata method defined on FileDatastream to 
  # run FITS characterization.
  def characterize 
    self.characterization.ng_xml = self.content.extract_metadata 
  end
end