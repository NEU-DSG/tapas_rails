module TapasRails
  module SolrDocumentBehavior
    def path
      send("Rails.application.routes.url_helpers.#{self.klass.underscore}_path", self.pid)
    end

    def public?
      read_groups.include?('public')
    end

    def read_groups
      Array(self[Ability.read_group_field])
    end

    def collections
      Array(self['collections_ssim'])
    end

    def project
      Array(self['project_pid_ssi']).first
    end

    def title
      Array(self['title_info_title_ssi']).first
    end
  end
end
