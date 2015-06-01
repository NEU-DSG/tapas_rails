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
    if params[:file].present?
      params[:file] = http_file_upload_to_hash(params[:file])
    end

    if params[:support_files].present?
      support_file_array = []
      params[:support_files].map do |key, support_file|
        support_file_array << http_file_upload_to_hash(support_file)
      end

      params[:support_files] = support_file_array
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params 
    @response[:message] = "CoreFile create/update in progress" 
    pretty_json(202) and return 
  end

  private
    def http_file_upload_to_hash(file_upload)
      fpath = file_upload.path 
      fname = file_upload.original_filename
      tmp   = Rails.root.join("tmp", "fname#{SecureRandom.hex}").to_s
      FileUtils.mv(fpath, tmp)
      return { :name => fpath, :path => tmp }
    end
end
