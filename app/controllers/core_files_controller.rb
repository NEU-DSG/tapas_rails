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

  def upsert
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
