class UpsertCollection
  include Concerns::Upserter 

  def upsert 
    begin 
      collection = Collection.find_by_did params[:did]

      if collection
        collection = Collection.find_by_did params[:did]
      else
        collection = Collection.new
        collection.did = params[:did]
        collection.depositor = params[:depositor] 
        collection.og_reference = [params[:project_did]]
        collection.save!
        
        community = Community.find_by_did(params[:project_did])
        if community
          collection.community = community
        else
          collection.collection = Collection.phantom_collection
        end
      end

      if params[:thumbnail].present?
        collection.add_thumbnail(:filepath => params[:thumbnail])
      end

      update_metadata!(collection)
    rescue => e 
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    ensure
      FileUtils.rm(params[:thumbnail]) if File.exists?(params[:thumbnail])
    end
  end

  private 

    def update_metadata!(collection)
      collection.mods.title = params[:title] if params[:title].present?
      collection.mods.abstract = params[:description] if params[:description].present?
      collection.drupal_access = params[:access] if params[:access].present?
      collection.save!
    end
end
