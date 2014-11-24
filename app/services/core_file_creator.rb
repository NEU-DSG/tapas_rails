class CoreFileCreator
  include Concerns::TapasObjectCreator

  # Create a CoreFile from a given set of params which map exactly
  # to the quirks of tight integration w. the Drupal Tapas system.
  # Note that this does not represent a particularly generalizable 
  # solution to anything and should be rewritten as part of any transition
  # to a unified system
  def create_record(run_cleanup = true) 
    begin 
      core     = nil 
      tei_file = nil

      core = CoreFile.new

      core.depositor        = params[:depositor]
      core.mass_permissions = "private" 
      core.nid              = params[:node_id]
     
      core.save!

      core.og_reference = params[:collection_id]
      # Attach this file to its collection, or add it to the phantom 
      # collection if it doesn't seem to have one.
      collection = Collection.find_by_nid(params[:collection_id])
      if collection
        core.collection_id = collection.id
      else
        core.collection_id = Collection.phantom_collection.pid
      end

      core.save!

      # Take params[:file] (always assumed to be a string file path as 
      # this makes enqueing this in a job possible), extract it to its 
      # own TEIFile object, and kick off inline derivation creation
      tei_file = TEIFile.new(depositor: params[:depositor])

      fname = Pathname.new(params[:file]).basename.to_s
      fblob = File.read(params[:file])
      tei_file.add_file(fblob, "content", fname)
      tei_file.depositor = params[:depositor]
      tei_file.canonize
      tei_file.save!
      tei_file.core_file = core
      tei_file.save!
      return core
    rescue => e
      # If the process doesn't complete, ensure files are cleaned out of the 
      # repository and that an email is sent (production environments only).
      core.destroy if core && core.persisted? 
      tei_file.destroy if tei_file && tei_file.persisted?
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e
    ensure
      # Always ensure that the file at params[:file] is deleted.
      FileUtils.rm(params[:file]) if run_cleanup
    end
  end
end
