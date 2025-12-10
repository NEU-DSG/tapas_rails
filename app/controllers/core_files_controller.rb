class CoreFilesController < ApplicationController
  include ApiAccessible
  include ModsDisplay::ControllerExtension
  include ControllerHelper
  include TapasRails::ViewPackages

  # self.copy_blacklight_config_from(CatalogController)

  configure_mods_display do
    identifier { ignore! }
  end

  # TODO investigate this after ruby version upgrades complete
  # skip_before_action :load_asset, :load_datastream, :authorize_download!

  # We can do better by using SOLR check instead of Fedora
  before_action :can_edit?, only: [:edit, :update, :destroy]
  before_action :can_read?, :only => :show
  # before_action :enforce_show_permissions, :only=>:show

  # self.search_params_logic += [:add_access_controls_to_solr_params]

  def index
    @page_title = "All CoreFiles"
    @results = CoreFile.order(updated_at: :desc)

    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  def new
    # original iteration of the New action; it includes logic to populate the list of file types and return them to the view for the user to select when creating a new core file
    #     @page_title = "Create New Record"
    #     model_type = RSolr.solr_escape "info:fedora/afmodel:Collection"
    #     projects = ActiveFedora::SolrService.query("has_model_ssim:\"#{RSolr.solr_escape "info:fedora/afmodel:Community"}\" && (project_members_ssim:\"#{current_user.id.to_s}\" OR depositor_tesim:\"#{current_user.id.to_s}\" OR project_admins_ssim:\"#{current_user.id.to_s}\" OR project_editors_ssim:\"#{current_user.id.to_s}\")")
    #     col_query = projects.map do |p|
    #       "project_pid_ssi: #{RSolr.solr_escape(p['id'])}"
    #     end
    #     query = "has_model_ssim: \"#{model_type}\" && (#{col_query.join(" OR ")})"
    #     count = ActiveFedora::SolrService.count(query)
    #     results = ActiveFedora::SolrService.query(query, fl: 'id, title_info_title_ssi', rows: count)
    #
    #     @collections =[]
    #     results.each do |res|
    #       if !res['title_info_title_ssi'].blank? && !res['id'].blank?
    #         @collections << [res['title_info_title_ssi'],res['id']]
    #       end
    #     end
    #     @core_file = CoreFile.new(:mass_permissions=>"public")
    #
    #     @file_types = [['TEI Record',""]]
    #     @sel_file_types = []
    #     CoreFile.all_ography_types.each do |o|
    #       @file_types << [o.titleize,o]
    #     end
    @page_title = "Create New Record"
    @collections = Collection.accessible_by(current_ability)
    @core_file = CoreFile.new(is_public: true)
    @users = User.order(:name)
  end

  def create
    @core_file = CoreFile.new(core_file_params.merge({ depositor_id: current_user.id }))

    if @core_file.save
      redirect_to @core_file, notice: "CoreFile created successfully"
    else
      @collections = Collection.accessible_by(current_ability)
      @users = User.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @core_file = CoreFile.find(params[:id])

    if @core_file.update(core_file_params)
      redirect_to @core_file, notice: "CoreFile updated successfully"
    else
      @collections = @core_file.project&.collections || Collection.accessible_by(current_ability)
      @users = @core_file.project&.users || User.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    file = CoreFile.find(params[:id])
    # FIXME: (charles) Should go to the collection where the user is, but the routes aren't set up RESTfully
    collection = file.collections.kept.first

    file.destroy!

    redirect_to collection
  end

  def edit
    @core_file = CoreFile.find(params[:id])
    @collections = @core_file.project.collections
    @users = @core_file.project.users
    @page_title = "Edit #{@core_file.title}"
  end

  def view_package_html
    # the :did attribute has been removed since it's not part of the new version of the app
    # but it may need to be added again to store legacy did's? not sure yet
    # decide what to do with did values that are associated with core files in the current prod database as those files are imported into the new database
    core_file_id = params[:id] || params[:did]

    @core_file = CoreFile.find_by_id(core_file_id)
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

  def show
    @core_file = CoreFile.find(params[:id])
  end

  def api_show
    @core_file = CoreFile.find_by_id(params[:id])

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
    # revise this method to format POST requests per the updated xml db docs:
    # request.set_form([['file', File.open('/path/to/file.xml')], ['collections', "#{f.c
    # ollection_ids}"]], 'multipart/form-data')
    # here, collections is an array of collection ids; make sure multiple collection ids use the correct delimiter,
    # comma-separated in a single string versus an array, e.g., collection_ids_array.map(&:to_s).join(','), and request authorization is basic_auth
    begin
      # Step 1: Find or create the CoreFile Object -
      # we do this here so that we have a stub record to
      # attach error messages & status tracking to.
      if CoreFile.exists?(params[:id])
        core_file = CoreFile.find_by_id(params[:id])
        core_file.mark_upload_in_progress!
      else
        core_file = CoreFile.create(id: params[:id],
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
          :tei_authors => params[:display_authors],
          :tei_contributors => params[:display_contributors],
          :"timeline-date" => params[:display_date],
          :title => params[:title]
        }

        @mods = TapasXq::GetMods.execute(params[:tei], opts)
      end

      # Step 4: Kick off an upsert job
      # This job will handle the actual upsert of the CoreFile object to xml db, baseX
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

  protected

  def can_edit?
    can? :manage, CoreFile.find(params[:id])
  end

  def can_read?
    can? :read, CoreFile.find(params[:id])
  end

  def core_file_params
    params.require(:core_file).permit(
      :canonical_object,
      :depositor,
      :description,
      :featured,
      :is_public,
      :title,
      :collection_ids => [],
      :tei_authors => [],
      :tei_contributors => [],
      :thumbnails => []
    )
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
