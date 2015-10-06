module Validations
  extend ActiveSupport::Concern

  included do 
    attr_reader :params
    attr_accessor :errors 

    def initialize(params)
      @params = params
      self.errors = []
    end

    def self.validate_upsert(params)
      self.new(params).validate_upsert
    end
  end

  def validate_did_and_create_reqs(klass, required_params)
    did_in_use = Did.exists_by_did?(params[:did])
    right_class = klass.exists_by_did?(params[:did])

    if did_in_use && !right_class
      self.errors << "Attempted to reuse a drupal id" 
    elsif !did_in_use
      required_params.each do |required_param|
        unless params[required_param].present?
          self.errors << "was missing required parameter #{required_param}"
        end
      end
    end
  end

  def validate_all_present_params
    params.each do |param_name, param_value|
      if self.respond_to? :"validate_#{param_name}"
        self.send(:"validate_#{param_name}")
      end
    end
  end

  def validate_nonblank_string(param)
    unless params[param].present? && params[param].is_a?(String)
      self.errors << "#{param} must be nonblank string" 
    end
  end

  def validate_file_and_type(param, valid_extensions)
    valid_classes = [ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile]
    param_class = params[param].class
    if !(param_class.in? valid_classes)
      self.errors << "#{param} must be a file upload" 
    elsif !(params[param].original_filename.split('.').last.in? valid_extensions)
      all_valid_extensions = valid_extensions.join(' or ')
      errors << "#{param} must be file with extension: #{all_valid_extensions}"
    end
  end

  def validate_array_of_strings(param)
    if !(params[param].is_a? Array)
      self.errors << "#{param} expects an array" 
    elsif !(params[param].all? { |p| p.is_a?(String) && p.present? })
      self.errors << "#{param} contained blank or non-string values"
    end
  end
end
