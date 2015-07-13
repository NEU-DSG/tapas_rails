module TapasObjectValidations
  extend ActiveSupport::Concern

  included do 
    attr_reader   :params
    attr_accessor :errors, :create_or_update

    def initialize(object_params)
      @params = (object_params || {}).with_indifferent_access
      @errors = []
    end
  end

  # This ensures that we are either using a did that doesn't exist 
  # (creating a new record) or updating a did for the expected object
  # class.
  def validate_class_correctness(klass)
    did = params[:did]

    # No errors if the Drupal ID is not in use
    if !(Did.exists_by_did? did)
      self.create_or_update = :create
      return true
    end

    if klass.where('did_ssim' => did).first?
      self.create_or_update = :update
      return true
    else
      errors << "Object with Drupal ID #{did} is not of the expected type"
      return false
    end
  end

  def validate_access_level 
    unless ['public', 'private', nil].include? params[:access]
      errors << "If specified, access must be one of: 'public', 'private'."
    end
  end

  def validate_required_attributes
    attrs = (create_or_update == :create) ? create_attrs : update_attrs

    errors_free = true

    attrs.each do |attr| 
      unless params[attr]
        errors << "Request was missing required param #{attr}." 
        errors_free = false
      end
    end

    return errors_free
  end
end
