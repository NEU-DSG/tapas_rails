module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  #can override methods from blacklight's app/helpers/blacklight/render_partials_helper here

  ##
  # Given a doc and a base name for a partial, this method will attempt to render
  # an appropriate partial based on the document format and view type.
  #
  # If a partial that matches the document format is not found,
  # render a default partial for the base name.
  #
  # @see #document_partial_path_templates
  #
  # @param [SolrDocument] doc
  # @param [String] base name for the partial
  # @param [Hash] locales to pass through to the partials
  def render_document_partial(doc, base_name, locals = {})
    format = if method(:document_partial_name).arity == 1
      Deprecation.warn self, "The #document_partial_name with a single argument is deprecated. Update your override to include a second argument for the 'base name'"
      document_partial_name(doc)
    else
      document_partial_name(doc, base_name)
    end

    view_type = document_index_view_type
    template = cached_view ['show', view_type, base_name, format].join('_') do
      find_document_show_template_with_view(view_type, base_name, format, locals)
    end
    if template
      template.render(self, locals.merge(document: doc))
    else
      ''
    end
  end

  # rubocop:disable Performance/Detect
  def find_document_show_template_with_view view_type, base_name, format, locals
    document_partial_path_templates.each do |str|
      partial = str % { action_name: base_name, format: format, index_view_type: view_type }
      template = lookup_context.find_all(partial, lookup_context.prefixes + [""], true, locals.keys + [:document], {}).first
      return template if template
    end
    nil
  end
end
