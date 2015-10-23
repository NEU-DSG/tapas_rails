class PropertiesDatastream < CerberusCore::Datastreams::PropertiesDatastream 

  use_terminology CerberusCore::Datastreams::PropertiesDatastream 

  extend_terminology do |t| 
    t.og_reference
    t.project_members
    t.drupal_access
    t.html_type
    t.upload_status
    t.upload_status_time
    t.errors_display
    t.errors_system
    t.stacktrace
  end

  def to_solr(hsh = {})
    hsh = super(hsh)

    if self.drupal_access.first 
      hsh['drupal_access_ssim'] = self.drupal_access.first
    end

    if self.html_type.first 
      hsh['html_type_ssi'] = self.html_type.first
    end

    if self.og_reference
      hsh['drupal_og_reference_ssim'] = self.og_reference
    end

    if self.upload_status
      hsh['upload_status_ssi'] = self.upload_status.first
    end

    if self.upload_status_time
      hsh['upload_status_time_dtsi'] = self.upload_status_time.first
    end

    return hsh
  end
end
