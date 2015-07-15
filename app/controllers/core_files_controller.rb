class CoreFilesController < ApplicationController
  include ApiAccessible

  skip_before_filter :load_asset, :load_datastream, :authorize_download!
  before_filter :load_core_file, :only => %i(teibp tapas_generic tei)

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

  def tei
    e = "Could not find TEI associated with this file.  Please retry in a "\
      "few minutes and contact an administrator if the problem persists."
    render_content_asset @core_file.canonical_object, e
  end

  def upsert
  end

  def add_metadata
  end

  private

  def create_temp_file(file)
    fpath = file.path
    fname = file.original_filename 
    
    tmp = Rails.root.join('tmp', "#{SecureRandom.hex}-#{fname}").to_s 
    FileUtils.mv(fpath, tmp) 
    return tmp
  end

  def load_core_file
    @core_file = CoreFile.find_by_did(params[:did]) 

    unless @core_file
      message = 'No record associated with this did was found.'
      render :text => message, :status => 404
    end
  end

  def render_content_asset(asset, error_msg)
    if asset && asset.content.content.present?
      render :text => asset.content.content 
    else 
      render :text => error_msg, :status => 404 
    end
  end    
end
