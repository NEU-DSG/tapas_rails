class CoreFileUpserter
  include Concerns::Upserter

  def upsert 
    begin 
      if Nid.exists_by_nid?(params[:nid])
        core_file = CoreFile.find_by_nid(params[:nid])
      else
        core_file = CoreFile.new
        core_file.nid = params[:nid]
      end
      update_core_file_metadata(core_file)
      update_core_file_tei_file(core_file) if params[:filepath]
    rescue => e 
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    ensure
      FileUtils.rm(params[:filepath]) if params[:filepath]
    end
  end

  private 

    def update_core_file_metadata(core_file)
      core_file.mods.title = params[:title] 
      core_file.depositor = params[:depositor] 
      core_file.drupal_access = params[:access] 
      core_file.og_reference = params[:collection] 

      collection = Collection.find_by_nid(params[:project]) 

      core_file.save! unless core_file.persisted?

      if collection
        core_file.collection = collection
      else
        core_file.collection = Collection.phantom_collection
      end
      
      core_file.save! 
    end

    def update_core_file_tei_file(core_file) 
      tei = core_file.canonical_object(:return_as => :models)

      unless tei
        tei = TEIFile.new
        tei.canonize
        tei.save! ; tei.core_file = core_file 
      end 

      tei.depositor = params[:depositor]
      tei.add_file(File.read(params[:filepath]), "content", params[:filename])
      tei.save!
    end
end

