class CollectionUpserter
  include Concerns::Upserter 

  def upsert 
    begin 
      if Nid.exists_by_nid?(params[:nid])
        collection = Collection.find_by_nid params[:nid]
        update_metadata(collection)
        collection.save!
      else
        collection = Collection.new
        collection.nid = params[:nid]
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

      project = Community.find_by_nid(params[:project])

      collection.save! unless collection.persisted?
      if project
        collection.community = project 
      else
        collection.collection = Collection.phantom_collection
      end
    end
end
