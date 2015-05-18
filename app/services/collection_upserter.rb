class CollectionUpserter
  include Concerns::Upserter 

  def upsert 
    begin 
      if Did.exists_by_did?(params[:did])
        collection = Collection.find_by_did params[:did]
        update_metadata(collection)
        collection.save!
      else
        collection = Collection.new
        collection.did = params[:did]
        update_metadata(collection)
        collection.save!
      end
    rescue => e 
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    end
  end

  private 

    def update_metadata(collection)
      collection.mods.title = params[:title]
      collection.depositor = params[:depositor]
      collection.drupal_access = params[:access]
      collection.og_reference = params[:project]

      project = Community.find_by_did(params[:project])

      collection.save! unless collection.persisted?
      if project
        collection.community = project 
      else
        collection.collection = Collection.phantom_collection
      end
    end
end
