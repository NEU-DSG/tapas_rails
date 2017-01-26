module TapasRails
  module SolrDocumentBehavior
    def path
      send("Rails.application.routes.url_helpers.#{self.klass.underscore}_path", self.pid)
    end
  end
end
