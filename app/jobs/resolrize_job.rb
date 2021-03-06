class ResolrizeJob
  def queue_name
    :tapas_rails_maintenance
  end

  def run
    require 'fileutils'
    job_id = "#{Time.now.to_i}-resolrize"
    FileUtils.mkdir_p "#{Rails.root}/log/#{job_id}"

    failed_pids_log = Logger.new("#{Rails.root}/log/#{job_id}/resolrize-job-failed-pids.log")

    conn = ActiveFedora::RubydoraConnection.new(ActiveFedora.config.credentials).connection

    conn.search(nil) { |object|
      begin
        if !object.datastreams.keys.include? "thumbnail_1"
          pid = object.pid
          TapasRails::Application::Queue.push(IndexJob.new(pid, job_id))
        end
      rescue Exception => error
        failed_pids_log.warn "#{Time.now} - Error processing PID: #{pid}"
        errors_for_pid = Logger.new("#{Rails.root}/log/#{job_id}/#{pid}.log")
        errors_for_pid.warn "#{Time.now} - #{$!.inspect}"
        errors_for_pid.warn "#{Time.now} - #{$!}"
        errors_for_pid.warn "#{Time.now} - #{$@}"
      end
    }
  end
end
