module CerberusCore::Datastreams
  # Basic Hydra rights metadata datastream with the addition of
  # some generally sensible extra validation.
  # FIXME (charles): Hydra::Datastream::RightsMetadata does not exist -- where did it go?
  # class ParanoidRightsDatastream < Hydra::Datastream::RightsMetadata
  #   use_terminology Hydra::Datastream::RightsMetadata

  #   VALIDATIONS = [
  #     {:key => :edit_users, :message => 'Depositor must have edit access', :condition => lambda { |obj| !obj.edit_users.include?(obj.properties.depositor.first) }},
  #     {:key => :edit_groups, :message => 'Public cannot have edit access', :condition => lambda { |obj| obj.edit_groups.include?('public') }},
  #     {:key => :edit_groups, :message => 'Registered cannot have edit access', :condition => lambda { |obj| obj.edit_groups.include?('registered') }}
  #   ]

  #   def validate(object)
  #     valid = true
  #     VALIDATIONS.each do |validation|
  #       if validation[:condition].call(object)
  #         object.errors[validation[:key]] ||= []
  #         object.errors[validation[:key]] << validation[:message]
  #         valid = false
  #       end
  #     end
  #     return valid
  #   end

  #   def prefix
  #     ""
  #   end
  # end
end
