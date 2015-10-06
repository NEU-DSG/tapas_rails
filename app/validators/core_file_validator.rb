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
    required_fields = %i(collection_dids tei depositor)
    validate_did_and_create_reqs(CoreFile, required_fields)
    # If any of these validations fail, there is no reason to proceed
    return errors if errors.any?

    validate_all_present_params
    return errors
  end

  def validate_collection_dids
    collection_dids = params[:collection_dids]

    unless collection_dids.is_a? Array
      self.errors << 'collection_dids must be an array, was a '\
       "#{collection_dids.class}"
      return
    end

    unless collection_dids.length > 0 
      self.errors << "collection_dids must have some values"
      return
    end

    # Retrieve solr documents for every collection did passed in.
    qs = collection_dids.map { |x| "did_ssim:#{RSolr.solr_escape(x)}" }
    qs = "(#{qs.join(' OR ')})" + ' AND active_fedora_model_ssi:Collection'
    collections = ActiveFedora::SolrService.query(qs)

    # Raise an error if there are fewer collections than collection_dids
    unless collection_dids.length == collections.length 
      self.errors << 'collection_dids references collections that do not exist'
      return
    end

    # Raise an error if there are collections that belong to multiple projects
    project_did = collections.first['is_member_of_ssim']
    unless collections.all? { |c| c['is_member_of_ssim'] == project_did }
      self.errors << 'collection_dids has collections that belong to multiple '\
        'projects'
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
