class CoreFilesController < CatalogController
  include ApiAccessible
  include ModsDisplay::ControllerExtension
  include ControllerHelper
  include TapasRails::ViewPackages

  self.copy_blacklight_config_from(CatalogController)

  configure_mods_display do
    identifier { ignore! }
  end

  skip_before_filter :load_asset, :load_datastream, :authorize_download!
  # We can do better by using SOLR check instead of Fedora
  before_filter :can_read?, only: [:show]
  before_filter :can_edit?, only: [:edit, :update]
  before_filter :enforce_show_permissions, :only=>:show

  self.search_params_logic += [:add_access_controls_to_solr_params]
  # before_filter :can_edit?, only: [:edit, :update]

  #This method displays all the core files created in the database
  def index
    @page_title = "All CoreFiles"
    self.search_params_logic += [:core_files_filter]
    (@response, @document_list) = search_results(params, search_params_logic)
    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  #This method is the helper method for index. It basically gets the core files
  # using solr queries
  def core_files_filter(solr_parameters, user_parameters)
    model_type = RSolr.solr_escape "info:fedora/afmodel:CoreFile"
    query = "has_model_ssim:\"#{model_type}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end

  #This method is used to create a new core file
  def new
    @page_title = "Create New Core File"
    model_type = RSolr.solr_escape "info:fedora/afmodel:Collection"
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\"", fl: 'id, title_info_title_ssi', rows: count)

    @collections =[]
    results.each do |res|
      if !res['title_info_title_ssi'].blank? && !res['id'].blank?
        @collections << [res['title_info_title_ssi'],res['id']]
      end
    end
    @core_file = CoreFile.new(:mass_permissions=>"public")
  end

  #This method contains the actual logic for creating a new core file
  def create
    begin
      params[:collection_dids] = params[:collections] if params[:collections]
      params[:depositor] = "000000000" #temp setting this until users integrated

      # Step 1: Find or create the CoreFile Object -
      # we do this here so that we have a stub record to
      # attach error messages & status tracking to.
      if params[:did].blank? && !params[:id].blank?
        params[:did] = params[:id]
      end
      if CoreFile.exists_by_did?(params[:did])
        core_file = CoreFile.find_by_did(params[:did])
      else
        core_file = CoreFile.create(did: params[:did],
                                    depositor: params[:depositor])
        core_file.permissions({person: "#{current_user.id}"}, "edit")
        core_file.mark_upload_in_progress!
      end

      # Step 1: Extract uploaded files to temporary locations if they exist
      if params[:tei]
        params[:tei] = create_temp_file params[:tei]
      else
        params[:tei] = create_temp_file_from_existing(core_file.canonical_object.fedora_file_path, core_file.canonical_object.filename)
      end

      if params[:support_files]
        params[:support_files] = create_temp_file params[:support_files]
      end

      if params[:thumbnail]
        thumbnail = create_temp_file params[:thumbnail]
        Content::UpsertThumbnail.execute(core_file, thumbnail)
      end

      if params[:mass_permissions]
        core_file.mass_permissions = params[:mass_permissions]
      end

      # Step 2: If TEI was provided, generate a MODS record that can be sent back
      # to Drupal to populate the validate metadata page provided after initial
      # file upload
      if params[:tei]
        opts = {
          :authors => params[:authors],
          :contributors => params[:contributors],
          :"timeline-date" => params[:display_date],
          :title => params[:title]
        }

        @mods = Exist::GetMods.execute(params[:tei], opts)
      end
      logger.info "passing params to job"

      # Step 3: Kick off an upsert job
      job = TapasObjectUpsertJob.new params
      # TapasRails::Application::Queue.push job #swap this for the line below when you're ready to push it to the queue instead of running it directly
      job.run

      # Step 4: Respond with MODS if it is available, otherwise send a generic
      # success message
      if @mods
        logger.info("mods is present - the redirect may be where it's failing")
      #   render :xml => @mods, :status => 202
        flash[:notice] = "Your file has been updated."
        redirect_to core_file
      else
        flash[:notice] = "Your file is being created. Check back soon."
        redirect_to "/core_files"
      #   @response[:message] = "Job processing"
      #   pretty_json(202) and return
      end

    rescue => e
      # core_file.set_default_display_error
      # core_file.set_stacktrace_message(e)
      # core_file.mark_upload_failed!
      raise e
    end
  end

  #This method is used to load the edit partial
  def edit
    @core_file = CoreFile.find(params[:id])
    model_type = RSolr.solr_escape "info:fedora/afmodel:Collection"
    community = "info:fedora/"+@core_file.project.pid
    count = ActiveFedora::SolrService.count("has_model_ssim:\"#{model_type}\" && is_member_of_ssim:\"#{community}\"")
    results = ActiveFedora::SolrService.query("has_model_ssim:\"#{model_type}\" && is_member_of_ssim:\"#{community}\"", fl: 'id, title_info_title_ssi', rows: count)
    logger.info results

    @collections =[]
    results.each do |res|
      if !res['title_info_title_ssi'].blank? && !res['id'].blank?
        @collections << [res['title_info_title_ssi'],res['id']]
      end
    end

    @page_title = "Edit #{@core_file.title}"
  end

  #This method contains the logic for editing/submission of edit form
  def update
    cf = CoreFile.find(params[:id])
    params[:did] = cf.did
    logger.warn("we are about to edit #{params[:did]}")
    logger.warn params
    create
  end

  def view_package_html
    @core_file = CoreFile.find_by_did(params[:did])
    if @core_file.blank?
      render :text => "Resource not found", :status => 404
    else
      @core_file.create_view_package_methods
      view_package = ViewPackage.where(:machine_name => "#{params[:view_package]}").to_a.first
      if !view_package.blank?
        e = "Could not find a #{view_package.human_name} representation of this object."\
          "Please retry in a few minutes."
        html = @core_file.send("#{view_package.machine_name}".to_sym)
        render_content_asset html, e
      else
        render :text => "The view package #{params[:view_package]} could not be found", :status => 422
      end
    end
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
    @mods_html = render_mods_display(@core_file).to_html.html_safe
    avail_views = available_view_packages
    @core_file.create_view_package_methods
    @view_packages = {}
    avail_views.each do |v|
      @view_packages[v[1]] = v[0]
    end
    @view_packages["XML View"] = :tei
    # get the default_view_package TODO - store this on collection, core_file like in drupal
    e = "Could not find TEI associated with this file.  Please retry in a "\
      "few minutes and contact an administrator if the problem persists."
  end

  def api_show
    @core_file = CoreFile.find_by_did(params[:did])

    if @core_file.upload_status.blank?
      @core_file.retroactively_set_status!
    end

    if @core_file.stuck_in_progress?
      @core_file.set_default_display_error
      @core_file.errors_system = ['Object was processing for more than five minutes']
      @core_file.mark_upload_failed!
    end

    @response = @core_file.as_json
    pretty_json(200) and return
  end

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

      # Step 2: Extract uploaded files to temporary locations if they exist
      if params[:tei]
        params[:tei] = create_temp_file params[:tei]
      end

      if params[:support_files]
        params[:support_files] = create_temp_file params[:support_files]
      end

      # Step 3: If TEI was provided, generate a MODS record that can be sent back
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

      # Step 4: Kick off an upsert job
      job = TapasObjectUpsertJob.new params
      TapasRails::Application::Queue.push job

      # Step 5: Respond with MODS if it is available, otherwise send a generic
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
      logger.error e
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
