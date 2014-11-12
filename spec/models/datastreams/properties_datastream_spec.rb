require 'spec_helper'

describe PropertiesDatastream do 
  let(:properties) { PropertiesDatastream.new } 

  describe "nid" do 
    it "can be written to and read from" do 
      properties.nid = "drupal_id"
      expect(properties.nid).to eq ["drupal_id"]
    end
  end

  describe "solrization" do 
    let(:solr_response) { properties.to_solr } 

    it "assigns nid information to the desired field name" do 
      properties.depositor = "wjackson@example.com"
      properties.nid       = "nid"

      expect(solr_response["drupal_nid_ssim"]).to eq "nid"
      expect(solr_response["depositor_tesim"]).to eq ["wjackson@example.com"]
    end
  end
end
