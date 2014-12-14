require 'spec_helper'

class NidTester < ActiveFedora::Base
  include Nid 
  has_metadata :name => "mods", :type => ModsDatastream
end

describe "The Nid module" do 
  let(:tester) { NidTester.new }

  after(:each) do 
    ActiveFedora::Base.destroy_all
  end

  it "gives access to nid setter/getter methods" do 
    expect(tester.respond_to? :nid).to be true 
    expect(tester.respond_to? :nid=).to be true 
  end

  it "allows us to look up objects by nid" do
    tester.nid = "3014"
    tester.save! 
    expect(NidTester.find_by_nid("3014").id).to eq tester.pid
  end

  it "returns nil when an item doesn't exist" do 
    expect(NidTester.find_by_nid("2111")).to be nil 
  end

  it "returns nil when an item of the wrong class is searched for" do 
    c = Collection.new
    c.nid = "nid:123" 
    c.depositor = "Johnny"
    c.save! 
    expect(NidTester.find_by_nid("nid:123")).to be nil 
  end

  it "allows us to check if a nid is already in use" do 
    expect(Nid.exists_by_nid?("not_used")).to be false 

    begin 
      c = Collection.new
      c.nid = "not_used" 
      c.depositor = "whomever" 
      c.save!

      expect(Nid.exists_by_nid? "not_used").to be true 
    ensure
      c.delete if c.persisted?
    end
  end

  it "doesn't define a per-model existence check" do 
    expect(NidTester.respond_to?(:exists_by_nid?)).to be false 
  end
end
