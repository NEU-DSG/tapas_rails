require 'spec_helper'

class OGReferenceTester < ActiveFedora::Base
  include OGReference
  has_metadata :name => "properties", :type => PropertiesDatastream 
end

class OGReferenceTesterTwo < ActiveFedora::Base
  include OGReference
  has_metadata :name => "properties", :type => PropertiesDatastream
end

describe "The OG Reference module" do 
  let(:tester) { OGReferenceTester.new }

  it "implements setters/getters for the OG module" do 
    tester.og_reference = "tapas_og"
    expect(tester.og_reference).to eq "tapas_og"
  end

  it "allows us to look up all objects with a certain og_reference" do 
    make_tester = Proc.new do |og_ref|
      o = OGReferenceTester.new
      o.og_reference = og_ref
      o.save!
      o
    end

    a = make_tester.call("111")
    b = make_tester.call('111')
    c = make_tester.call('112')

    d = OGReferenceTesterTwo.new
    d.og_reference = "111" 
    d.save! 

    result = OGReference.find_all_in_og('111')
    pids   = result.map { |solr_doc| solr_doc.id }

    expect(result.length).to eq 3 
    expect(pids).to include a.pid 
    expect(pids).to include b.pid
    expect(pids).to include d.pid
  end

  after(:all) do 
    OGReferenceTester.delete_all
    OGReferenceTesterTwo.delete_all
  end
end
