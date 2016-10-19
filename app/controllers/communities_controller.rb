class CommunitiesController < CatalogController
  self.copy_blacklight_config_from(CatalogController)

  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Community upsert in progress"
    pretty_json(202) and return
  end

  # def destroy
  #   @community.descendents.each { |descendent| descendent.destroy }
  #   @community.destroy
  #   @response[:message] = "Project successfully destroyed"
  #   pretty_json(200) and return
  # end

  def index
    @page_title = "All Projects"
    self.search_params_logic += [:communities_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    render 'shared/index'
  end

  def communities_filter(solr_parameters, user_parameters)
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Community"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end
end
