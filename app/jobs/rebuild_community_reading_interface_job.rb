class RebuildCommunityReadingInterfaceJob
  attr_accessor :pid

  def initialize(pid)
    self.pid = pid
  end

  def queue_name
    :tapas_rails_maintenance
  end

  def run
    if Community.exists?(self.pid)
      project = Community.find(self.pid)
      project.descendent_collections.each do |col|
        # logger.info "col is #{col.pid}"
        # rerun the ographies first
        all_verbs = ["is_personography_for_ssim:\"info:fedora/#{col.pid}\"",
          "is_orgography_for_ssim:\"info:fedora/#{col.pid}\"",
          "is_bibliography_for_ssim:\"info:fedora/#{col.pid}\"",
          "is_otherography_for_ssim:\"info:fedora/#{col.pid}\"",
          "is_odd_file_for_ssim:\"info:fedora/#{col.pid}\"",
          "is_placeography_for_ssim:\"info:fedora/#{col.pid}\"",]

        all_verbs = all_verbs.join(" OR ")
        # logger.info all_verbs
        descendent_ographies = SolrService.query(all_verbs)
        # logger.info descendent_ographies
        descendent_ographies.each do |file|
          if CoreFile.exists?(file['id'])
            # logger.info "ography file #{file['id']}"
            RebuildReadingInterfaceJob.perform(file['id'])
          end
        end
        # then run the rest of the files
        col.descendent_records.each do |file|
          if !file.is_ography?
            # logger.info "non ography #{file.pid}"
            RebuildReadingInterfaceJob.perform(file.pid)
          end
        end
      end
    end
  end
end
