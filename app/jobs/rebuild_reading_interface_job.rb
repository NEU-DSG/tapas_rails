class RebuildReadingInterfaceJob
  @queue = 'tapas_rails_maintenance'

  def self.perform(did)
    begin
      core_file = CoreFile.find_by_did(did)
      return false unless core_file && core_file.project

      core_file.mark_upload_in_progress!

      tei = core_file.canonical_object
      return false unless tei

      tmpfile = Tempfile.new('ri_rebuild')
      tmpfile.write(tei.content.content.force_encoding('UTF-8'))
      tmpfile.rewind

      Content::UpsertReadingInterface.execute_all(core_file, tmpfile.path)
      core_file.mark_upload_complete!
    rescue => e
      core_file.set_default_display_error
      core_file.set_stacktrace_message(e)
      core_file.mark_upload_failed!
      raise e
    ensure
      tmpfile.close if tmpfile
      tmpfile.unlink if tmpfile
    end
  end
end
