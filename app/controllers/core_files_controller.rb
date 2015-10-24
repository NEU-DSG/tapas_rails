class CoreFilesController < ApplicationController
  include ApiAccessible
  include ModsDisplay::ControllerExtension

  configure_mods_display do 
    identifier { ignore! } 
  end

  skip_before_filter :load_asset, :load_datastream, :authorize_download!

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
    # Calling perform directly causes the job to execute inline, 
    # rather than being queued for processing later.
    RebuildReadingInterfaceJob.perform(params[:did])
  end

  def show 
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
    rescue e 
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
