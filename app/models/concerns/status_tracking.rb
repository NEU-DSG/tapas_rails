module StatusTracking
  extend ActiveSupport::Concern 

  included do 
    has_attributes :upload_status, :upload_status_time, :validation_errors,
      :stacktrace, :datastream => :properties, :multiple => false  
  end

  def self.valid_status_code?(code)
    code.in? %w(SUCCESS INPROGRESS FAILED_INVALID FAILED_SYSTEMERR)
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
end
