class PropertiesDatastream < CerberusCore::Datastreams::PropertiesDatastream 

  use_terminology CerberusCore::Datastreams::PropertiesDatastream 

  extend_terminology do |t| 
    t.og_reference
    t.project_members
    t.drupal_access
    t.html_type
  end

  def to_solr(hsh = {})
    hsh = super(hsh)

    if self.html_type.first 
      hsh["html_type_ssi"] = self.html_type.first
    end

    if self.og_reference.first
      hsh["drupal_og_reference_ssim"] = self.og_reference.first 
    end

    return hsh
  end
end
