require 'spec_helper' 

describe Community do 

  describe "parents" do 
    after(:all) { ActiveFedora::Base.delete_all } 
    
    it "can be accessed via #community" do 
      parent = Community.create
      child  = Community.create(community: parent)

      expect(child.community).to eq parent
    end
  end

  describe "Traversals" do 
    before :all do 
      @community = Community.create 

      @kid_comm = Community.create(community: @community)
      @kid_col  = Collection.create(depositor: "Will", community: @community)
      @des_file = CoreFile.create(depositor: "Will", collection: @kid_col)
    end

    subject(:community) { @community }

    after(:all) { ActiveFedora::Base.delete_all }
    
    its(:children) { should match_array [@kid_comm, @kid_col] }

    its(:communities) { should match_array [@kid_comm] } 

    its(:collections) { should match_array [@kid_col] } 
    
    its(:descendent_records) { should match_array [@des_file] }
  end
end
