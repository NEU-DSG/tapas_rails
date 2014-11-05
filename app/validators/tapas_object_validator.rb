module TapasObjectValidator
  extend ActiveSupport::Concern

  included do 
    attr_reader   :params
    attr_accessor :errors

    def initialize(object_params)
      params_hash = object_params || {}
      @params = params_hash.with_indifferent_access
      @errors = []
    end
  end

  def no_params?
    unless self.params.present?
      errors << "Object had no parameters or did not exist" 
      return true
    end
  end

  # Requires that a method 'required_attributes' be defined on the containing
  # class that returns an array of necessary attribute names.
  def validate_required_attributes
    required_attributes.each do |attribute|
      unless params[attribute]
        errors << "Object was missing required attribute #{attribute}"
      end
    end
  end
end