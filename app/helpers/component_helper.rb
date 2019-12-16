module ComponentHelper
  include Blacklight::ComponentHelperBehavior

  ##
  # Render "document actions" area for search results view
  # (normally renders next to title in the list view)
  #
  # @param [SolrDocument] document
  # @param [Hash] options
  # @option options [String] :wrapping_class
  # @return [String]
  def render_index_doc_actions(document, options={})
    wrapping_class = options.delete(:wrapping_class) || "index-document-functions"
    rendered = render_filtered_partials(blacklight_config.view_config(document_index_view_type).document_actions, { document: document }.merge(options))
    content_tag("div", rendered, class: wrapping_class) unless rendered.blank?
  end

  def render_filtered_partials(partials, options={}, &block)
    content = []
    partials.select { |_, config| evaluate_if_unless_configuration config, options }.each do |key, config|
      config.key ||= key
      rendered = render(partial: config.partial || key.to_s, locals: { document_action_config: config }.merge(options))
      if block_given?
        yield config, rendered
      else
        content << rendered
      end
    end
    safe_join(content, "\n") unless block_given?
  end

end
