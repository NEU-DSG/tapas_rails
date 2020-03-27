# Mostly internal helper module.
module CerberusCore::Concerns::Relatable 
  extend ActiveSupport::Concern 

  module ClassMethods
    # A convenience method for defining the relate_to_x methods found in 
    # the Community and Collection base models, which are themselves convenience
    # methods over the relationship assertions provided by ActiveFedora.  Useful
    # primarily for enforcing (sorta) the expected relationships tying the graph 
    # together. 
    def relation_asserter(method, rel_name, rel_type, rel_class)
      if rel_class 
        self.send(method, rel_name, :property => rel_type, :class_name => rel_class)
      else
        self.send(method, rel_name, :property => rel_type)
      end
    end
  end
end