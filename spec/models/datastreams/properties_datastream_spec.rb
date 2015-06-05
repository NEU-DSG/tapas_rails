require 'spec_helper'

describe PropertiesDatastream do 
  let(:properties) { PropertiesDatastream.new }
  let(:solr_hash)  { properties.to_solr }

  it "implements the og reference field." do 
    properties.og_reference = "111"
    expect(properties.og_reference.first).to eq "111"
  end

  it "implements the project members field." do 
    properties.project_members = ["1", "2", "3"]
    expect(properties.project_members).to match_array ["1", "2", "3"]
  end

  it "implements the html_type field" do 
    properties.html_type = "tapas_generic" 
    expect(properties.html_type).to eq ["tapas_generic"]
  end

  it "implements the drupal access field." do 
    properties.drupal_access = "public" 
    expect(properties.drupal_access.first).to eq "public" 
  end

  it "solrizes correctly" do 
    properties.depositor = "William Jackson"
    properties.og_reference = "321" 
    properties.project_members = ["1", "2"]
    properties.html_type = "teibp"

    expect(solr_hash["depositor_tesim"]).to eq ["William Jackson"]
    expect(solr_hash["drupal_og_reference_ssim"]).to eq "321"
    expect(solr_hash["html_type_ssi"]).to eq "teibp" 
  end
end
