require 'spec_helper'

class MintedPidTest < ActiveFedora::Base
  include CerberusCore::Concerns::AutoMintedPid

  has_metadata "DC", type: CerberusCore::Datastreams::DublinCoreDatastream
end

describe CerberusCore::Concerns::AutoMintedPid do 
  let(:test)   { MintedPidTest.new }
  let(:config) { Dummy::Application.config } 

  context "With auto generation enabled" do 
    # Ensure valid configuration is always set for each of these tests
    before(:each) do 
      config.cerberus_core.auto_generate_pid = true
    end

    it "generates a pid on create" do 
      expect { MintedPidTest.new }.not_to raise_error 
      expect(test.pid).to include "changeme:"
    end

    it "doesn't change the pid of already persisted objects" do 
      original_pid = test.pid
      test.save!
      new_instantiation = MintedPidTest.find(original_pid)
      expect(new_instantiation.pid).to eq original_pid 
    end
  end

  context "With auto generation disabled" do 
    before(:each) { config.cerberus_core.auto_generate_pid = false }

    it "doesn't auto generate a pid" do 
      expect(test.pid).to eq nil
    end
  end
end
