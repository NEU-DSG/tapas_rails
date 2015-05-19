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
      collection.mods.title = params[:title] if params[:title].present?
      collection.mods.abstract = params[:description] if params[:description].present?
      collection.depositor = params[:depositor] if params[:depositor].present?
      collection.drupal_access = params[:access] if params[:access].present?
      collection.og_reference = params[:project_did] if params[:project_did].present?

      project = Community.find_by_did(params[:project_did])

      collection.save! unless collection.persisted?
      
      if project
        collection.community = project 
      else
        collection.collection = Collection.phantom_collection
      end
    end
end
