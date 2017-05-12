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
  end
end
