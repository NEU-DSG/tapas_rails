class CoreFileValidator 
  include Validations

  attr_accessor :errors
  attr_reader :params

  def initialize(params)
    @params = params 
    self.errors = []
  end

  def self.validate_upsert(params)
    self.new(params).validate_upsert
  end

  def validate_upsert
    required_fields = %i(collection_dids tei depositor file_types)
    validate_did_and_create_reqs(CoreFile, required_fields)
    # If any of these validations fail, there is no reason to proceed
    return errors if errors.any?

    validate_all_present_params
    return errors
  end

  def validate_collection_dids
    collections = params[:collection_dids]

    unless collections.is_a? Array
      self.errors << 'collection_dids must be an array, was a '\
       "#{collections.class}"
      return
    end

    # :collection_dids must be an array of Drupal IDs belonging to Collections that 
    # have already been ingested into the repository
    collections.each do |cdid|
      unless Collection.exists_by_did?(cdid)
        self.errors << 'collection_dids contained a did that belonged to no '\
          "collection, mystery did was: #{cdid}"
      end
    end
  end

  def validate_tei
    validate_file_and_type(:tei, %w(xml))
  end

  # Display title must be a non-blank string
  def validate_display_title
    validate_nonblank_string :display_title
  end

  def validate_display_authors
    validate_array_of_strings :display_authors
  end

  def validate_display_contributors
    validate_array_of_strings :display_contributors
  end

  def validate_display_date
    date = params[:display_date]
    begin
      Date.iso8601(date)
    rescue ArgumentError
      self.errors << "display_date must be ISO8601 formatted, was #{date}"
    end
  end

  def validate_support_files
    validate_file_and_type(:support_files, %w(zip))
  end

  def validate_depositor
    validate_nonblank_string :depositor
  end

  def validate_file_types
    file_types = params[:file_types]

    unless file_types.is_a? Array
      self.errors << 'file_types must be an array' 
      return
    end

    file_types.each do |file_type|
      unless file_type.in? CoreFile.all_ography_types
        self.errors << "#{file_type} is not a valid option for file_types"
      end
    end
  end
end
