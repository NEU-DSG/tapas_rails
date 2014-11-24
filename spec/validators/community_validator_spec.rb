require 'spec_helper'

describe CommunityValidator do 
  include ValidatorHelpers

  describe "On POST #create" do 
    let(:params) { { title: "valid",
                     description: "valid", 
                     members: ["valid"], 
                     nid: "111",
                     action: "create" } }

    it "raises no error with valid params" do 
      expect(validation_errors(params).length).to eq 0
    end

    it "raises an error with no nid attr" do 
      expect(validation_errors(params.except :nid).length).to eq 1
    end

    it "raises an error with no title param" do 
      expect(validation_errors(params.except :title).length).to eq 1
    end

    it "raises an error with no description param" do 
      expect(validation_errors(params.except :description).length).to eq 1
    end

    it "raises an error with no members param" do 
      expect(validation_errors(params.except :members).length).to eq 1
    end
  end
end
