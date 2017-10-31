class PropertiesDatastream < CerberusCore::Datastreams::PropertiesDatastream

  use_terminology CerberusCore::Datastreams::PropertiesDatastream

  extend_terminology do |t|
    t.authors
    t.contributors
    t.og_reference
    t.project_members
    t.project_editors
    t.project_admins
    t.drupal_access
    t.html_type
    t.upload_status
    t.upload_status_time
    t.errors_display
    t.errors_system
    t.stacktrace
    t.institutions
  end

  def to_solr(hsh = {})
    hsh = super(hsh)

    if self.project_members.first
      hsh['project_members_ssim'] = self.project_members
    end

    if self.project_editors.first
      hsh['project_editors_ssim'] = self.project_editors
    end

    if self.project_admins.first
      hsh['project_admins_ssim'] = self.project_admins
    end

    if self.authors.first
      hsh['authors_ssim'] = self.authors.first
    end

    if self.contributors.first
      hsh['contributors_ssim'] = self.contributors.first
    end

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

    if self.depositor
      if User.exists?(self.depositor[0])
        hsh['depositor_name_ssim'] = User.find(self.depositor[0]).name
      end
    end

    return hsh
  end
end
