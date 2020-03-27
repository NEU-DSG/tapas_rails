# Implements traversals over the graph of core records, collections, 
# and communities.  Included in Collections and Communities and in 
# SolrDocumentBehavior.
# ==== Options
# All the methods defined in this module take the following argument:
# * +:as+ - A symbol dictating how the results of the Solr Query 
#   ought to be returned to the user.  The default option is :models, 
#   which returns every query object cast to its ActiveFedora representation.
#   In cases where speed is significant or the whole object is unneeded, one can 
#   also specify :raw or :query_result to get the hash exactly as it is returned 
#   by ActiveFedora or :solr_doc to get the object as a SolrDocument instance.
#   All return type options can be singular or plural.
module CerberusCore::Concerns::Traversals
  # Creates a new QueryService object from the given object. 
  # Ought to know how to create from a fedora level model, 
  # a SolrDocument, or a raw response hash.  
  def new_query
    CerberusCore::Services::QueryService.create_from_object(self)
  end

  # Fetch all children (immediate descendents) of this fedora object.
  def children(as = :models)
    new_query.get_children as
  end

  # Fetch all descendents of this fedora object.
  def descendents(as = :models) 
    new_query.get_descendents as 
  end

  # Fetch all children which are named in CORE_RECORD_CLASSES
  # for this fedora object.
  def records(as = :models) 
    new_query.get_child_records as
  end

  # Fetch all descendents which are named in CORE_RECORD_CLASSES
  # for this fedora object.
  def descendent_records(as = :models) 
    new_query.get_descendent_records as 
  end

  # Fetch all children which are named in COLLECTION_CLASSES
  # for this fedora object.
  def collections(as = :models) 
    new_query.get_child_collections as 
  end

  # Fetch all descendents which are named in COLLECTION_CLASSES
  # for this fedora object.
  def descendent_collections(as = :models) 
    new_query.get_descendent_collections as 
  end

  # Fetch all children which are named in COMMUNITY_CLASSES
  # for this fedora object.
  def communities(as = :models) 
    new_query.get_child_communities as
  end

  # Fetch all descendents which are named in COMMUNITY_CLASSES
  # for this fedora object.
  def descendent_communities(as = :models)
    new_query.get_descendent_communities as
  end

  def canonical_object(as = :models)
    new_query.get_canonical_object as 
  end

  def content_objects(as = :models)
    new_query.get_content_objects as 
  end
end
