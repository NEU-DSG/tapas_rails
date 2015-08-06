class CollectionsController < ApplicationController
  include ApiAccessible

  def upsert 
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params 
    @response[:message] = "Collection upsert accepted" 
    pretty_json(202) and return 
  end

  def destroy
    collection = Collection.find_by_did(params[:did]) 

    if collection
      collection.delete
      @response[:message] = "Collection successfully deleted."
      pretty_json(200) and return
    else
      @response[:message] = "No collection with did #{params[:did]} found."
      pretty_json(422) and return 
    end
  end
end
