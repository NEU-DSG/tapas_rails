# Mostly internal helper module.
module CerberusCore::Concerns::Relatable
  extend ActiveSupport::Concern

  module ClassMethods
    # A convenience method for defining the relate_to_x methods found in
    # the Community and Collection base models, which are themselves convenience
    # methods over the relationship assertions provided by ActiveFedora.  Useful
    # primarily for enforcing (sorta) the expected relationships tying the graph
    # together.
    # FIXME: (charles) This module no longer works with latest updates
    # Fails on :property keyword, then on trying to send to ActiveFedora::Associations::Builder::BelongsTo
    def relation_asserter(method, rel_name, rel_type, rel_class)
    end
    # def relation_asserter(method, rel_name, rel_type, rel_class)
    #   if rel_class
    #     self.send(method, rel_name, :predicate => rel_type, :class_name => rel_class)
    #   else
    #     self.send(method, rel_name, :predicate => rel_type)
    #   end
    # end
  end
end
