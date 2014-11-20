class PropertiesDatastream < CerberusCore::Datastreams::PropertiesDatastream 

  use_terminology CerberusCore::Datastreams::PropertiesDatastream 

  extend_terminology do |t| 
    t.og_reference
    t.project_members
  end

  def to_solr(hsh = {})
    hsh = super(hsh)

    if self.og_reference.first
      hsh["drupal_og_reference_ssim"] = self.og_reference.first 
    end

    return hsh
  end
end
