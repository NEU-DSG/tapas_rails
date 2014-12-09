class CollectionCreator
  include Concerns::TapasObjectCreator

  def create_record
    begin
      collection = Collection.new
      collection.nid = params[:nid]
      collection.mods.title = params[:title]
      collection.depositor = params[:depositor]
      collection.og_reference = params[:project]
      collection.drupal_access = params[:access]
      collection.save!

      project = Community.find_by_nid(params[:project])

      if project
        collection.community = Community.find(project.id)
      else
        collection.collection = Collection.phantom_collection
      end

      collection.save!
      return collection
    rescue => e 
      collection.destroy if collection.persisted?
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e
    end
  end
end
