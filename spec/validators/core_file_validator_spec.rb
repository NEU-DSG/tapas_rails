require 'spec_helper'

describe CoreFileValidator do 
  include ValidatorHelpers

  describe "on POST #create" do 
    let(:params) do 
      { :file => "default",
        :nid => "default",
        :access => "public",
        :collection => "default",
        :depositor => "default",
        :action => "create" }
    end

    it "raises an error if two CoreFiles would have the same nid." do 
      begin
        c = CoreFile.new.tap do |c| 
          c.depositor = "wjackson"
          c.nid       = "default" 
          c.save!
        end

        expect(validation_errors(params).length).to eq 1
        msg = "Object with nid of default already exists - aborting."
        expect(validation_errors(params).first).to eq msg
      ensure
        c.destroy
      end
    end

    it "raises an error if no access level is present" do 
      expect(validation_errors(params.except :access).length).to eq 1
    end

    it "raises an error if no node_id is present" do 
      expect(validation_errors(params.except :nid).length).to eq 1
    end

    it "raises an error if no depositor is present" do 
      expect(validation_errors(params.except :depositor).length).to eq 1
    end

    it "raises an error if no collection id is present" do 
      expect(validation_errors(params.except :collection).length).to eq 1
    end

    it "raises an error if no file is present" do
      expect(validation_errors(params.except :file).length).to eq 1 
    end
  end
end
