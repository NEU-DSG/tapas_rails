module CerberusCore::Services
  # Given a pid and the name of the class that the pid object
  # is an instance of, this service handles querying Solr for 
  # children and descendents.  See the Traversals concern for 
  # a cleaner interface into this service, which may admittedly
  # need some polish.
  class QueryService 

    attr_accessor :pid, :class_name

    def initialize(pid, class_name)
      self.pid = pid
      self.class_name = class_name 
    end

    # There are three ways to 'have' a Fedora object.  The first is 
    # holding the actual fedora ORM object.  The second is the raw 
    # response hash returned by a query to solr, and the third is 
    # that response hash pushed into a SolrDocument.  This object 
    # creates a new QueryService based on any of the three.
    def self.create_from_object(object) 
      if (object.class.name == "SolrDocument") || object.is_a?(Hash)
        id = object["id"]
        class_name = object["active_fedora_model_ssi"]

        CerberusCore::Services::QueryService.new(id, class_name) 
      else
        CerberusCore::Services::QueryService.new(object.pid, object.class.name) 
      end
    end

    # See Traversals.
    def get_children(as = :models)
      query_with_models(:all, as)
    end

    # See Traversals.
    def get_descendents(as = :models) 
      results = query_with_models(:all, :query_result)

      results.each do |r|
        id    = r["id"]
        model = r["active_fedora_model_ssi"]
        qs    = QueryService.new(id, model)
        more_kids = qs.query_with_models(:all, :query_result)
        results.push(*more_kids)
      end

      parse_return_statement(as, results)  
    end

    # See Traversals.
    def get_child_records(as = :models)
      query_with_models(:files, as)
    end

    # See Traversals.
    def get_descendent_records(as = :models)
      filter_descendent_query(:files, as)
    end

    # See Traversals.
    def get_child_collections(as = :models) 
      query_with_models(:collections, as) 
    end

    # See Traversals.
    def get_descendent_collections(as = :models)
      filter_descendent_query(:collections, as)
    end

    # See Traversals.
    def get_child_communities(as = :models)
      query_with_models(:communities, as) 
    end

    # See Traversals.
    def get_descendent_communities(as = :models) 
      filter_descendent_query(:communities, as) 
    end

    # Return all content objects for pid.  If pid doesn't point at 
    # a CoreRecord type object, or just one with no content, 
    # return an empty array.
    def get_content_objects(as = :models) 
      query   = "is_part_of_ssim:#{full_pid}"
      row_count = ActiveFedora::SolrService.count(query)
      results = ActiveFedora::SolrService.query(query, rows: row_count)
      parse_return_statement(as, results)
    end

    # Return the canonical object for this pid.  If pid doesn't point
    # at a CoreRecord type object, or just one with no content, 
    # return nil. 
    def get_canonical_object(as = :models)
      intermediate = get_content_objects(:query_result) 
      intermediate.keep_if { |x| x["canonical_tesim"] == ['yes'] }
      parse_return_statement(as, intermediate).first
    end

    protected 

    #:nodoc:
    def query_with_models(model_types, as)
      models = model_array(model_types)
      if models.any?
        models = construct_model_query(models)

        member_of        = "is_member_of_ssim:#{full_pid}"
        affiliation_with = "has_affiliation_ssim:#{full_pid}"

        query   = "#{models} AND (#{member_of} OR #{affiliation_with})"
        row_count = ActiveFedora::SolrService.count(query)
        results = ActiveFedora::SolrService.query(query, rows: row_count) 

        parse_return_statement(as, results)
      else
        return []
      end
    end

    private

    #:nodoc:
    def full_pid(param_pid = nil)
      if param_pid
        return "\"info:fedora/#{param_pid}\""
      else
        return "\"info:fedora/#{self.pid}\""
      end
    end

    #:nodoc:
    def construct_model_query(model_names)
      models = model_names.map{|x|"\"#{x}\""}.join(" OR ")
      return "active_fedora_model_ssi:(#{models})" 
    end

    #:nodoc:
    def filter_descendent_query(model_type, as) 
      qr   = get_descendents(:query_result) 

      models = model_array(model_type) 

      qr.keep_if { |r| models.include? r["active_fedora_model_ssi"] } 

      parse_return_statement(as, qr) 
    end

    #:nodoc:
    def parse_return_statement(as, results) 
      if [:query_result, :query_results, :raw, :raws].include? as
        return results 
      elsif [:models, :model].include? as 
        results.map! do |result| 
          ActiveFedora::Base.find(result["id"], cast: true) 
        end
      elsif [:solr_documents, :solr_document, :solr_docs, :solr_doc].include? as
        results.map! { |result| ::SolrDocument.new(result) }
      else
        raise "Invalid return type specified"
      end
    end

    #:nodoc:
    def model_array(type)
      const = class_name.constantize 

      records     = []
      folders     = []
      communities = []

      check = Proc.new do |x, y| 
        const.public_methods.include?(x) && y.include?(type)
      end

      if check.call(:core_file_types, [:files, :all])
        records = const.core_file_types
      end

      if check.call(:collection_types, [:collections, :all])
        folders = const.collection_types
      end

      if check.call(:community_types, [:communities, :all])
        communities = const.community_types
      end

      return records + folders + communities
    end
  end
end
