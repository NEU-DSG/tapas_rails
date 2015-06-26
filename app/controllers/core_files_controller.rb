class CoreFilesController < ApplicationController
  include ApiAccessible
  include Hydra::Controller::DownloadBehavior

  skip_before_filter :load_asset, :load_datastream, :authorize_download!
  before_filter :load_core_file, :only => %i(show_teibp show_tapas_generic)

  def show_teibp 
    render_asset(@core_file.teibp)
  end

  def show_tapas_generic 
    render_asset(@core_file.tapas_generic)
  end

  def upsert
    if params[:files].present?
      params[:files] = create_temp_file params[:files]
    end

    if params[:support_files.present?
      params[:support_files] = create_temp_file params[:support_files]    
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params 
    @response[:message] = "CoreFile update/create in progress" 
    pretty_json(202) and return
  end

  private

  def create_temp_file(file)
    fpath = file.path
    fname = file.original_filename 
    
    tmp = Rails.root.join('tmp', "#{SecureRandom.hex}-#{fname}").to_s 
    FileUtils.mv(fpath, tmp) 

    tmp 
  end

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
