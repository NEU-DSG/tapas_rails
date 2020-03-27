require 'spec_helper'

class RightsValidationTester < ActiveFedora::Base
  include CerberusCore::Concerns::ParanoidRightsDatastreamDelegations
  include CerberusCore::Concerns::ParanoidRightsValidation

  def depositor
    self.properties.depositor.first 
  end

  has_metadata name: "rightsMetadata", type: TestRightsDatastream
  has_metadata name: "properties", type: TestPropertiesDatastream
end

describe TestRightsDatastream do 
  let(:obj) { RightsValidationTester.new } 
  after(:each) { obj.destroy if obj.persisted? }  

  describe "Inherited Functionality:" do 
    it "carries over validations" do 
      expect(obj.rightsMetadata.respond_to? :validate).to be true
    end
  end

  describe "Permissions logic" do 

    it "can assign and read users" do 
      expect(obj.read_users).to eq []
      obj.permissions({person: "jjj"}, "read") 
      expect(obj.read_users).to match_array ["jjj"]
    end

    it "can assign and read groups" do 
      expect(obj.edit_groups).to eq []
      obj.permissions({group: "j3"}, "edit") 
      expect(obj.edit_groups).to match_array ["j3"] 
    end

    it "can assign mass permissions" do 
      obj.mass_permissions = 'public' 
      expect(obj.read_groups).to include "public" 
      expect(obj.mass_permissions).to eq "public"
      obj.mass_permissions = 'private' 
      expect(obj.read_groups).not_to include "public" 
      expect(obj.mass_permissions).to eq "private"
    end
  end
end