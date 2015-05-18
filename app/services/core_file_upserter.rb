class CoreFileUpserter
  include Concerns::Upserter

  def upsert 
    begin 
      if Did.exists_by_did?(params[:did])
        core_file = CoreFile.find_by_did(params[:did])
      else
        puts "creating core file"
        core_file = CoreFile.new
        core_file.did = params[:did]
      end
      update_core_file_metadata(core_file)
      update_core_file_tei_file(core_file) if params[:file]
    rescue => e 
      puts "error ahhh"
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    ensure
      FileUtils.rm(params[:file][:path]) if params[:file][:path]
    end
  end

  private 

    def update_core_file_metadata(core_file)
      core_file.mods.title = params[:title] 
      core_file.depositor = params[:depositor] 
      core_file.drupal_access = params[:access] 
      core_file.og_reference = params[:collection] 

      collection = Collection.find_by_did(params[:project]) 

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

      filename = params[:file][:name]
      filecontent = File.read(params[:file][:path])
      current_filename = tei.content.label 
      current_filecontent = tei.content.content 
      # If the filename and content are identical to the filename
      # and content of the most recent version, don't store the file.
      unless (current_filename == filename) && (current_filecontent == filecontent)
        tei.add_file(filecontent, "content", filename)
      end

      tei.save!
    end
end

