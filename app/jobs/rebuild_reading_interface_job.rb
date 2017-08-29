class RebuildReadingInterfaceJob
  @queue = 'tapas_rails_maintenance'
  def self.perform(did)
    begin
      if CoreFile.exists?("#{did}")
        core_file = CoreFile.find("#{did}")
      else
        core_file = CoreFile.find_by_did("#{did}")
      end

      if !(core_file)
        raise 'Could not find record with specified Drupal ID'
      elsif !(core_file.project)
        raise 'Attempted to rebuild reading interface for record'\
          ' not associated with any project'
      elsif !(core_file.canonical_object.content.content.present?)
        raise 'Attempted to rebuild reading interface for object'\
          ' with no tei content'
      end

      core_file.mark_upload_in_progress!
      tei = core_file.canonical_object

      tmpfile = Tempfile.new(['ri_rebuild', '.xml'])
      tmpfile.write(tei.content.content.force_encoding('UTF-8'))
      tmpfile.rewind

      Content::UpsertReadingInterface.execute_all(core_file, tmpfile.path)
      core_file.mark_upload_complete!
    rescue => e
      if core_file
        msg = 'Reading interface rebuild failed.  Please reattempt'\
          ' and contact an administrator if the problem continues'
        core_file.errors_display = [msg]
        core_file.set_stacktrace_message(e)
        core_file.mark_upload_failed!
      end
      this_log = Logger.new("#{Rails.root}/log/#{job_id}/rebuild_job.log")
      this_log.error e
      raise ActiveFedora::ObjectNotFoundError
    ensure
      tmpfile.close if tmpfile
      tmpfile.unlink if tmpfile
    end
  end
end
