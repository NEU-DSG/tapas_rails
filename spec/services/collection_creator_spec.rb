require 'spec_helper' 

describe CollectionCreator do 
  describe "A clean run" do 
    before :all do 
      @project = Community.new
      @project.nid = "555"
      @project.save!

      @params = { nid: "111",
                  title: "Test Collection",
                  project: "555" }
      @collection = CollectionCreator.create_record(@params)
    end

    after :all do 
      @project.destroy if @project.persisted?
      @collection.destroy if @collection.persisted?
    end

    it "creates the requested collection" do 
      expect(Collection.find_by_nid("111")).not_to be nil 
    end

    it "assigns the collection a nid" do 
      expect(@collection.nid).to eq @params[:nid]
    end

    it "assigns the project reference to the og field" do 
      expect(@collection.og_reference).to eq @params[:project]
    end

    it "assigns the collection a title" do 
      expect(@collection.mods.title).to eq [@params[:title]]
    end

    it "assigns the collection to its project" do 
      expect(@collection.community_id).to eq @project.pid
    end
  end

  describe "A run with a nonexistent project" do 
    before :all do 
      @params = { nid: "111",
                  title: "Test Collection",
                  project: "555" }

      @collection = CollectionCreator.create_record(@params)
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "assigns the collection to the phantom collection" do 
      expect(@collection.community_id).to be nil 
      expect(@collection.collection_id).to eq Rails.configuration.phantom_collection_pid
    end

    it "writes the og reference field for future reference" do 
      expect(@collection.og_reference).to eq @params[:project]
    end
  end

  describe "A run that errors out", :type => :mailer do 
    after(:all) { ActiveFedora::Base.delete_all }

    it "persists no objects and triggers an exception notification" do 
      params = { 
        nid: "111",
        project: "333",
        title: "Invalid Collection"
      }

      Collection.any_instance.stub(:collection=).and_raise(RuntimeError)

      expect { CollectionCreator.create_record(params) }.to raise_error(RuntimeError)
      expect(Collection.find_by_nid "111").to be nil 
      expect(ActionMailer::Base.deliveries.length).to eq 1
    end
  end
end
