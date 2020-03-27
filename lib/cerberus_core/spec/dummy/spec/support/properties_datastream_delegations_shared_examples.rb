require 'spec_helper'

RSpec.shared_examples "A Properties Delegator" do 
  let(:delegator) { described_class.new } 

  it "forwards the expected methods" do 
    methods = [:in_progress?, :tag_as_in_progress, :tag_as_completed, 
               :canonize, :uncanonize, :canonical?, :depositor, 
               :thumbnail_list, :download_filename, :download_filename=]

    expect(methods.all? { |x| delegator.respond_to? x }).to be true 
  end

  it "sets edit permissions for the depositor" do 
    delegator.depositor = "test" 
    expect(delegator.depositor).to eq("test") 
    expect(delegator.edit_users).to include("test")
  end
end
