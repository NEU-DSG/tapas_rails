module StatusTracking
  extend ActiveSupport::Concern 

  included do 
    has_attributes :upload_status, :upload_status_time, :stacktrace,
      :datastream => :properties, :multiple => false  
    has_attributes :errors_display, :errors_system, :datastream => :properties,
      :multiple => true
  end

  def self.valid_status_code?(code)
    code.in? %w(COMPLETE INPROGRESS FAILED)
  end

  def set_status_code(code)
    if StatusTracking.valid_status_code?(code)
      self.upload_status = code 
      self.upload_status_time = Time.now.utc.iso8601
    else
      raise "Invalid status code passed" 
    end
  end

  def set_default_display_error
    self.errors_display = ['A system error occurred while processing'\
                           ' your file.  Please reattempt upload and contact'\
                           ' an administrator if the problem continues.']
  end

  def set_stacktrace_message(e)
    error_str = "#{e.backtrace.first} : #{e.message} (#{e.class}) \n"\
    "#{e.backtrace.drop(1).join("\n")}"
    self.stacktrace = error_str
  end

  def mark_upload_failed
    set_status_code('FAILED')
  end

  def mark_upload_in_progress
    set_status_code('INPROGRESS')
  end

  def mark_upload_complete
    set_status_code('COMPLETE')
  end

  def mark_upload_failed!
    set_status_code!('FAILED')
  end

  def mark_upload_in_progress!
    set_status_code!('INPROGRESS')
  end

  def mark_upload_complete!
    set_status_code!('COMPLETE')
  end

  def upload_failed?
    upload_status == 'FAILED'
  end

  def upload_complete?
    upload_status == 'COMPLETE'
  end

  def upload_in_progress?
    upload_status == 'INPROGRESS'
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
