class CoreFilesController < ApplicationController
  include ApiAccessible
  include ModsDisplay::ControllerExtension
  include TapasRails::ViewPackages

  # self.copy_blacklight_config_from(CatalogController)

  configure_mods_display do
    identifier { ignore! }
  end

  # TODO investigate this after ruby version upgrades complete
  # skip_before_action :load_asset, :load_datastream, :authorize_download!

  before_action :can_edit?, only: [:edit, :update, :destroy]
  before_action :can_read?, :only => :show
  # before_action :enforce_show_permissions, :only=>:show

  # self.search_params_logic += [:add_access_controls_to_solr_params]

  def index
    @page_title = "All CoreFiles"

    @search = CoreFileSearch.new(params)
    @results = @search.result

    respond_to do |format|
      format.html { render :template => 'shared/index' }
      format.js { render :template => 'shared/index', :layout => false }
    end
  end

  def new
    @page_title = "Create New Record"
    @collections = Collection.accessible_by(current_ability)
    @core_file = CoreFile.new(is_public: true)
    @users = User.order(:name)
  end

  def create
    file = CoreFile.create!(core_file_params.merge({ depositor_id: current_user.id }))
    file.set_authors(params[:core_file][:author_ids])

    redirect_to file
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
    @collections = Collection.accessible_by(current_ability)
    @users = User.order(:name)
    @page_title = "Edit #{@core_file.title}"
  end

  #This method contains the logic for editing/submission of edit form
  def update
    cf = CoreFile.find(params[:id])
    cf.update(core_file_params)

    redirect_to cf
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

  def show
    @core_file = CoreFile.find(params[:id])
    @view_packages = [["Styled TEI", 'tei2html'], ["Raw XML", 'teibp']]
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
      :title,
      :author_ids => [],
      :collection_ids => [],
      :contributor_ids => [],
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
