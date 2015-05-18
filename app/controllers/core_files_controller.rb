class CoreFilesController < ApplicationController
  include ApiAccessible

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
