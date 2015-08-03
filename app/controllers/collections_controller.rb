class CollectionsController < ApplicationController
  include ApiAccessible

  def upsert 
    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params 
    @response[:message] = "Collection upsert accepted" 
    pretty_json(202) and return 
  end

  def delete
    collection = Collection.find_by_did(params[:did]) 

    if collection
      collection.delete
      @response[:message] = "#{collection.title} successfully deleted."
      pretty_json(200) and return
    else
      @response[:message] = "No collection with did #{params[:did]} found."
      pretty_json(404) and return 
    end
  end
end
