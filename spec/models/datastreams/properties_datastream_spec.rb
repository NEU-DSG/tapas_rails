require 'spec_helper'

describe PropertiesDatastream do 
  let(:properties) { PropertiesDatastream.new }
  let(:solr_hash)  { properties.to_solr }

  it "implements the og reference field." do 
    properties.og_reference = "111"
    expect(properties.og_reference.first).to eq "111"
  end

  it "solrizes correctly" do 
    properties.depositor = "William Jackson"
    properties.og_reference = "321" 

    expect(solr_hash["depositor_tesim"]).to eq ["William Jackson"]
    expect(solr_hash["drupal_og_reference_ssim"]).to eq "321"
  end
end
