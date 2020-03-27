require 'spec_helper'

describe TestPropertiesDatastream do
  let (:properties) { TestPropertiesDatastream.new } 

  describe "Inherited Functionality:" do
    describe "Canonization" do 
      it "can be set" do 
        expect(properties.canonical?).to eq false 
        properties.canonize
        expect(properties.canonical?).to eq true 
      end

      it "can be unset" do 
        properties.canonize
        properties.uncanonize
        expect(properties.canonical?).to eq false 
      end
    end

    describe "Download Filename" do 
      it "can be set" do 
        properties.download_filename = "test" 
        expect(properties.download_filename).to eq ["test"]
      end
    end

    describe "In Progress State" do 
      it "can be set" do 
        expect(properties.in_progress?).to eq false 
        properties.tag_as_in_progress
        expect(properties.in_progress?).to eq true 
      end

      it "can be unset" do 
        properties.tag_as_in_progress
        properties.tag_as_completed
        expect(properties.in_progress?).to eq false 
      end
    end

    describe "Thumbnail lists" do 

      it "start empty" do 
        properties.thumbnail_list = []
      end

      it "can be added to" do 
        thumbs = ["path/to/obj?dsid=1", "path/to/obj?dsid=2"]

        properties.thumbnail_list = thumbs
        expect(properties.thumbnail_list).to match_array thumbs 

        properties.thumbnail_list = ["path/to/obj?dsid=3"]
        expect(properties.thumbnail_list).to match_array(["path/to/obj?dsid=3"])
      end
    end

    describe "Parent id" do

      it "starts empty" do 
        expect(properties.parent_id).to eq([])
      end

      it "can be assigned a single value" do 
        properties.parent_id = "test:111" 
        expect(properties.parent_id).to eq(["test:111"]) 
      end
    end
  end

  describe "Extended Functionality:" do 
    describe "Test attribute term" do  
      it "exists and can be set + read" do 
        properties.test_attribute = "test"
        expect(properties.test_attribute).to match_array(["test"])
      end
    end

    describe "get depositor" do 
      it "fetches the first defined depositor" do 
        expect(properties.get_depositor).to eq(nil) 

        properties.depositor = "emp:111" 
        expect(properties.get_depositor).to eq("emp:111")
      end
    end
  end
end