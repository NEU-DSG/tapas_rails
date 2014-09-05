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

  def validate_required_attributes
    required_attributes.each do |attribute|
      unless params[attribute]
        errors << "Object was missing required attribute #{attribute}"
      end
    end
  end

  def validate_parent_helper(expected_parent_classes)
    pid = params[:parent]

    if ActiveFedora::Base.exists?(pid) && pid
      parent = ActiveFedora::Base.find(pid, cast: true)

      unless expected_parent_classes.include? parent.class 
        errors << <<-eos 
        Object at specified parent pid #{pid} was a
        #{parent.class}.  Must be one of: 
        #{expected_parent_classes.join(", ") }
        eos
      end
    elsif pid
      errors << "No object exists at the specified parent pid of #{pid}"
    end
  end

  def shared_required_attributes
    [:title]
  end
end