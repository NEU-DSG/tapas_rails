class CoreFilesController < ApplicationController
  include ApiAccessible
  include Hydra::Controller::DownloadBehavior

  skip_before_filter :load_asset, :load_datastream, :authorize_download!
  before_filter :load_core_file, :only => %i(show_teibp show_tapas_generic)

  skip_before_filter :authenticate_api_request, :only => [:show_teibp, :show_tapas_generic]

  def show_teibp 
    render_asset(@core_file.teibp)
  end

  def show_tapas_generic 
    render_asset(@core_file.tapas_generic)
  end

  def upsert
    # If params[:file] is set to anything, we assume 
    # we need to perform a file content update - extract 
    # filepath and filename
    if params[:files].present?
      fpath = params[:files].path
      fname = params[:files].original_filename
      tmp = Rails.root.join("tmp", "#{SecureRandom.hex}-#{fname}").to_s
      FileUtils.mv(fpath, tmp)
      params[:files] = tmp
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params 
    @response[:message] = "CoreFile create/update in progress" 
    pretty_json(202) and return 
  end

  private

  def load_core_file
    @core_file = CoreFile.find_by_did(params[:did]) 

    unless @core_file 
      @response[:message] = "No content with that did exists" 
      pretty_json(422) and return 
    end
  end

  def render_asset(asset)
    unless asset 
      @response[:message] = "That content doesn't exist!" 
      pretty_json(422) and return 
    end

    @asset = asset 
    @ds = asset.datastreams["content"]
    send_content
  end
end
