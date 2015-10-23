module StatusTracking
  extend ActiveSupport::Concern 

  included do 
    has_attributes :upload_status, :upload_status_time, :stacktrace,
      :datastream => :properties, :multiple => false  
    has_attributes :validation_errors, :datastream => :properties, 
      :multiple => true
  end

  def self.valid_status_code?(code)
    code.in? %w(SUCCESS INPROGRESS FAILED_USERERR FAILED_SYSTEMERR)
  end

  def set_status_code(code)
    if StatusTracking.valid_status_code?(code)
      self.upload_status = code 
      self.upload_status_time = DateTime.now.iso8601.to_s
    else
      raise "Invalid status code passed" 
    end
  end

  def set_status_code!(code)
    set_status_code(code)
    save!
  end

  # Checks if an object has been sitting in the 'in progress'
  # state for more than five minutes, which is a good indication
  # that something has gone wrong and upload should be retried.
  def stuck_in_progress?
    if upload_status_time.present? && upload_status == 'INPROGRESS'
      5.minutes.ago > upload_status_time
    else
      return false
    end
  end
end
