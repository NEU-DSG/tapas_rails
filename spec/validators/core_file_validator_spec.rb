require 'spec_helper'

describe CoreFileValidator do 
  include ValidatorHelpers

  describe "on POST #upsert" do 
    let(:params) do 
      { :file => "default",
        :nid => "default",
        :access => "public",
        :collection => "default",
        :depositor => "default",
        :action => "upsert" }
    end

    it "raises no error if nid belongs to a preexisting CoreFile" do 
      begin
        c = CoreFile.new.tap do |c| 
          c.depositor = "wjackson"
          c.nid       = params[:nid]
          c.save!
        end

        expect(validation_errors(params).length).to eq 0
      ensure
        c.destroy
      end
    end

    it "raises an error if nid belongs to an object that isn't a CoreFile" do 
      begin 
        c = Community.new
        c.nid = params[:nid]
        c.save!

        expect(validation_errors(params).length).to eq 1 
      ensure
        c.delete if c.persisted?
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
