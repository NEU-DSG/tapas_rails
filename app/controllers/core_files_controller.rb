class CoreFilesController < CatalogController
  # include ApiAccessible
  include ModsDisplay::ControllerExtension

  configure_mods_display do
    identifier { ignore! }
  end

  skip_before_filter :load_asset, :load_datastream, :authorize_download!

  def index
    @page_title = "All CoreFiles"
    self.search_params_logic += [:communities_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    render 'shared/index'
  end

  # def show #inherited from catalog controller
  # end

  def communities_filter(solr_parameters, user_parameters)
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:CoreFile"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end
  def new
    @page_title = "Create New Core File"
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Collection"
    # results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi')
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi', rows: count)

    @arr =[]
    results.each do |res|
      # @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      if !res['title_info_title_ssi'].blank? && !res['did_ssim'].blank? && res['did_ssim'].count > 0
        @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      end
    end
    @core_file = CoreFile.new
  end

  def create
    collection = Collection.find("#{params[:core_file][:collection]}")
    params[:core_file].delete("collection")
    @core_file = CoreFile.new(did: params[:did], depositor: params[:depositor], title: params[:title])
    # @core_file.did = @core_file.pid
    # @core_file.depositor = "000000000"
    # @core_file.save!
    @core_file.collection = collection
    # Start upsert job with params for the file upload
    logger.warn(params[:tei])
    logger.info(params) 
    if params[:tei]
      params[:tei] = create_temp_file params[:tei]
    end

    if params[:tei]
      opts = {
        :authors => params[:authors],
        :contributors => params[:contributors],
        :title => params[:title]
      }

      # @mods = Exist::GetMods.execute(params[:tei], opts)
    end

    # Kick off an upsert job
    job = TapasObjectUpsertJob.new params
    # TapasRails::Application::Queue.push job
    job.run

    # Respond with MODS if it is available, otherwise send a generic
    # success message
    # if @mods
    #   render :xml => @mods, :status => 202
    # else
      # @response[:message] = "Job processing"
      # @core_file.save!
    redirect_to @core_file and return
    # end
    # redirect_to @core_file and return
  end

  def edit
    model_type = ActiveFedora::SolrService.escape_uri_for_query "info:fedora/afmodel:Collection"
    # results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi')
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'did_ssim, title_info_title_ssi', rows: count)

    @arr =[]
    results.each do |res|
      # @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      if !res['title_info_title_ssi'].blank? && !res['did_ssim'].blank? && res['did_ssim'].count > 0
        @arr << [res['title_info_title_ssi'],res['did_ssim'][0]]
      end
    end
    @core_file = CoreFile.find(params[:id])

    @page_title = "Edit #{@core_file.title}"
  end

  def update
    collection = Collection.find("#{params[:core_file][:collection]}")
    params[:core_file].delete("collection")
    @core_file = CoreFile.find(params[:id])
    # @core_files = CoreFile.find_by_did(params[:id])
    @core_file.update_attributes(params[:core_file])
    @core_file.save!
    @core_file.collection = collection
    @core_file.save!
    redirect_to @core_file and return
  end

  def teibp
    e = "Could not find TEI Boilerplate representation of this object.  "\
      "Please retry in a few minutes."
    render_content_asset @core_file.teibp, e
  end

  def tapas_generic
    e = "Could not find a Tapas Generic representation of this object.  "\
      "Please retry in a few minutes."
    render_content_asset @core_file.tapas_generic, e
  end

  def mods
    @html = render_mods_display(@core_file).to_html
    render :text => @html
  end

  def tei
    e = "Could not find TEI associated with this file.  Please retry in a "\
      "few minutes and contact an administrator if the problem persists."
    render_content_asset @core_file.canonical_object, e
  end

  def rebuild_reading_interfaces
    RebuildReadingInterfaceJob.perform(params[:did])
    @response[:message] = "Record updated successfully"
    pretty_json(200) and return
  end

  def show #inherited from catalog controller
    @core_file = CoreFile.find(params[:id])
    @cid=(params[:id])
  end

  # def show
  #   @core_file = CoreFile.find_by_did(params[:did])
  #
  #   if @core_file.upload_status.blank?
  #     @core_file.retroactively_set_status!
  #   end
  #
  #   if @core_file.stuck_in_progress?
  #     @core_file.set_default_display_error
  #     @core_file.errors_system = ['Object was processing for more than five minutes']
  #     @core_file.mark_upload_failed!
  #   end
  #
  #   @response = @core_file.as_json
  #   pretty_json(200) and return
  # end

  def upsert
    begin
      # Step 1: Find or create the CoreFile Object -
      # we do this here so that we have a stub record to
      # attach error messages & status tracking to.
      if CoreFile.exists_by_did?(params[:did])
        core_file = CoreFile.find_by_did(params[:did])
        core_file.mark_upload_in_progress!
      else
        core_file = CoreFile.create(did: params[:did],
                                    depositor: params[:depositor])
        core_file.mark_upload_in_progress!
      end

      # Step 1: Extract uploaded files to temporary locations if they exist
      if params[:tei]
        params[:tei] = create_temp_file params[:tei]
      end

      if params[:support_files]
        params[:support_files] = create_temp_file params[:support_files]
      end

      # Step 2: If TEI was provided, generate a MODS record that can be sent back
      # to Drupal to populate the validate metadata page provided after initial
      # file upload
      if params[:tei]
        opts = {
          :authors => params[:display_authors],
          :contributors => params[:display_contributors],
          :"timeline-date" => params[:display_date],
          :title => params[:title]
        }

        @mods = Exist::GetMods.execute(params[:tei], opts)
      end

      # Step 3: Kick off an upsert job
      job = TapasObjectUpsertJob.new params
      TapasRails::Application::Queue.push job

      # Step 4: Respond with MODS if it is available, otherwise send a generic
      # success message
      if @mods
        render :xml => @mods, :status => 202
      else
        @response[:message] = "Job processing"
        pretty_json(202) and return
      end
    rescue => e
      core_file.set_default_display_error
      core_file.set_stacktrace_message(e)
      core_file.mark_upload_failed!
      raise e
    end
  end

  private

  def render_content_asset(asset, error_msg)
    if asset && asset.content.content.present?
      render :text => asset.content.content
    else
      render :text => error_msg, :status => 404
    end
  end



end
