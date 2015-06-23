require 'spec_helper'

describe CoreFileValidator do 
  include ValidatorHelpers
  include FileHelpers

  describe "on POST #upsert" do 
    let(:params) do 
      { :files => "default",
        :did => "default",
        :access => "public",
        :collection_dids => ["default", "default2"],
        :file_type => "tei_content",
        :depositor => "default",
        :action => "upsert" }
    end

    it "raises no error if did belongs to a preexisting CoreFile" do 
      begin
        c = CoreFile.new.tap do |c| 
          c.depositor = "wjackson"
          c.did       = params[:did]
          c.save!
        end

        expect(validation_errors(params).length).to eq 0
      ensure
        c.destroy
      end
    end

    it "raises an error if did belongs to an object that isn't a CoreFile" do 
      begin 
        c = Community.new
        c.did = params[:did]
        c.save!

        expect(validation_errors(params).length).to eq 1 
      ensure
        c.delete if c.persisted?
      end
    end

    context "When creating a file it" do 
      it "raises an error if no access level is present" do 
        expect(validation_errors(params.except :access).length).to eq 1
      end

      it "raises an error if no drupal id is present" do 
        expect(validation_errors(params.except :did).length).to eq 1
      end

      it "raises an error if no depositor is present" do 
        expect(validation_errors(params.except :depositor).length).to eq 1
      end

      it "raises an error if no file_type is set" do 
        expect(validation_errors(params.except :file_type).length).to eq 1 
      end

      it "raises an error if no collection id is present" do 
        expect(validation_errors(params.except :collection_dids).length).to eq 1
      end

      it "raises an error with no files param" do 
        expect(validation_errors(params.except :files).length).to eq 1 
      end
    end

    context "When updating a file it" do 
      before(:all) do 
        @core = CoreFile.create(:did => "default", :depositor => "depositor")
      end

      after(:all) { @core.destroy }

      it "requires only a did" do 
        p = { :did => "default", :action => "upsert" }
        expect(validation_errors(p).length).to eq 0
      end
    end
  end
end
