class CoreFilesController < ApplicationController
  include JsonApiAccessible

  def create
    respond_to do |format| 

      format.json do 
        render :nothing => true, status: 200
      end
    end
  end
end
