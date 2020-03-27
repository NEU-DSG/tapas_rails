require 'spec_helper'

describe SolrDocument do 
  let(:core_file) { CoreFile.new} 

  def doc 
    SolrDocument.new(core_file.to_solr) 
  end

  describe "Traversals" do 
    let(:doc) { SolrDocument.new(@community.to_solr) } 

    before :all do 
      @community = Community.create 

      @collection = Collection.new 
      @collection.depositor = "Will" 
      @collection.community = @community
      @collection.save! 

      @core_file = CoreFile.new 
      @core_file.depositor  = "Will" 
      @core_file.collection = @collection
      @core_file.save! 
    end

    it "can be run" do 
      expect(@community.children).to match_array [@collection]  
    end

    it "can return other SolrDocuments" do 
      result = @community.descendents(:solr_docs)

      expect(result.map{|x| x.class.name}).to match_array ["SolrDocument", "SolrDocument"]
      expect(result.map{|x| x["id"]}).to match_array [@collection.pid, @core_file.pid]
    end

    after :all do 
      @community.destroy
      @collection.destroy 
      @core_file.destroy 
    end
  end

  describe "Mods metadata access" do 
    pending "Figure out how people access the mods ds."
  end

  describe "System info access" do 
    it "allows us to get the fedora model of this object" do 
      expect(doc.klass).to eq "CoreFile"
    end

    it "allows us to get the pid of this object" do 
      # Have to persist the core file for it to have a pid
      core_file.depositor = "will" ; core_file.save!
      expect(doc.pid).to eq core_file.pid 
    end
  end

  describe "Rights metadata access" do 
    it "allows us to check an object's mass permissions" do
      expect(doc.mass_permissions).to eq "private"

      core_file.permissions({group: "public"}, "read")
      expect(doc.mass_permissions).to eq "public"
    end

    it "allows us to see an object's read users" do 
      core_file.permissions({person: "Will"}, "read")
      expect(doc.read_users).to eq ["Will"]
    end

    it "allows us to see an object's edit users" do 
      core_file.permissions({person: "Will"}, "edit")
      expect(doc.edit_users).to eq ["Will"]
    end

    it "allows us to see an object's edit groups" do 
      core_file.permissions({group: "Willump"}, "edit") 
      expect(doc.edit_groups).to eq ["Willump"]
    end

    it "allows us to see an object's read groups" do 
      core_file.permissions({group: "Willump"}, "read")
      expect(doc.read_groups).to eq ["Willump"]
    end
  end

  describe "Properties datastream access" do 
    it "allows us to read an objects depositor" do 
      core_file.depositor = "Will" 
      expect(doc.depositor).to eq "Will" 
    end

    it "allows us to check whether an object is in progress" do 
      core_file.tag_as_in_progress
      expect(doc.in_progress?).to be true

      core_file.tag_as_completed
      expect(doc.in_progress?).to be false
    end

    it "allows us to check if this object is canonical" do 
      expect(doc.canonical?).to be false 
      core_file.canonize
      expect(doc.canonical?).to be true 
    end

    it "allows us to read an object's parent id" do 
      expect(doc.parent_id).to eq "" 
      core_file.properties.parent_id = "blah" 
      expect(doc.parent_id).to eq "blah" 
    end 

    it "allows us to access the thumbnail list" do 
      thumbs = ["url1", "url2", "url3"]
      core_file.thumbnail_list = thumbs
      expect(doc.thumbnail_list).to match_array thumbs
    end
  end

  describe "Class method" do 

    describe "find_by_pid" do

      before(:all) { @wumpus = Wumpus.create }  

      it "raises an error if the requested pid doesn't exist in Solr" do 
        d = CerberusCore::PidNotFoundInSolrError
        expect{ SolrDocument.find_by_pid("blargh") }.to raise_error d 
      end

      it "returns a solr document" do 
        pid = @wumpus.pid 
        response = SolrDocument.find_by_pid(pid) 
        expect(response.class).to be SolrDocument 
        expect(response["id"]).to eq pid 
      end

      after(:all) { @wumpus.destroy } 
    end
  end
end
