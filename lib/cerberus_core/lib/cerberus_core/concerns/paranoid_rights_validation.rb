# Including this module ensures that the validations specified by 
# the paranoid rights datastream are actually run.  Note that this is 
# included/not included as appropriate in core_record.rb/content_object.rb/etc. 
module CerberusCore::Concerns
  module ParanoidRightsValidation
    extend ActiveSupport::Concern 

    included do 
      validate :paranoid_validations 

      def paranoid_validations
        self.rightsMetadata.validate(self)
      end

      private :paranoid_validations
    end
  end
end