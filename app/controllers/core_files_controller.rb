class CoreFilesController < ApplicationController
  include ApiAccessible
  include Hydra::Controller::DownloadBehavior

  skip_before_filter :load_asset, :load_datastream, :authorize_download!

  def show_tfc 
    cf = CoreFile.find_by_did(params[:did]) 

    unless cf 
      @response[:message] = "No content with that did exists"
      pretty_json(422) and return
    end

    @asset = cf.tfc.first 
    
    unless @asset 
      @response[:message] = "Object with did #{params[:did]}" \
        " had no Tapas Friendly Copy (TFC) associated with it." 
      pretty_json(422) and return 
    end

    @ds = @asset.datastreams["content"]
    send_content
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
end
