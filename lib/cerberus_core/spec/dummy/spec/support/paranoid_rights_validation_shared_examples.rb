require 'spec_helper'

RSpec.shared_examples "a paranoid rights validator" do 
  let(:validator) { described_class.new }

  after(:each) { validator.destroy if validator.persisted? } 

  it "disallows save with public edit access" do 
    validator.permissions({group: "public"}, "edit") 
    expect { validator.save! }.to raise_error(ActiveFedora::RecordInvalid) 
  end

  it "disallows save with registered edit access" do 
    validator.permissions({group: "registered"}, "edit")
    expect { validator.save! }.to raise_error(ActiveFedora::RecordInvalid)
  end

  it "disallows save with depositor with no edit access" do 
    validator.properties.depositor = "Will Jackson"
    validator.permissions({person: "Will Jackson"}, "none") 
    expect { validator.save! }.to raise_error(ActiveFedora::RecordInvalid) 
  end
end