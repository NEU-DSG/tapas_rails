class CollectionsController < CatalogController
  include ApiAccessible

  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Collection upsert accepted"
    pretty_json(202) and return
  end

  def index
    @page_title = "All Collections"
    self.search_params_logic += [:collections_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    render 'shared/index'
  end

  # def show #inherited from catalog controller
  # end

  def collections_filter(solr_parameters, user_parameters)
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Collection"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end

  def new
    @page_title = "Create New Collection"
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Community"
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi', rows: count)
    @arr =[]
    results.each do |res|
      if !res['title_info_title_ssi'].blank? && !res['did_ssim'].blank? && res['did_ssim'].count > 0
        @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      end
    end
    @collection = Collection.new
  end

  def create
    community = Community.find("#{params[:collection][:community]}")
    params[:collection].delete("community")
    @collection = Collection.new(params[:collection])
    @collection.did = @collection.pid
    @collection.depositor = "000000000"
    @collection.save! #object must be saved before community can be assigned
    @collection.community = community
    @collection.save!
    redirect_to @collection and return
  end

  def edit
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Community"
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi', rows: count)
    @arr =[]
    results.each do |res|
      if !res['title_info_title_ssi'].blank? && !res['did_ssim'].blank? && res['did_ssim'].count > 0
        @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      end
    end
    @collection = Collection.find(params[:id])
    @page_title = "Edit #{@collection.title}"
  end

  def update
    @collection = Collection.find(params[:id])
    @collection.update_attributes(params[:collection])
    @collection.save!
    redirect_to @collection and return
  end
end
