require 'spec_helper' 

describe Collection do    
  describe "Parent Queries" do 
    context "With parent collection" do 
      before(:all) do 
        @parent = Collection.new(:depositor => "Will") 
        @parent.save! 

        @child = Collection.new(:depositor => "Will")
        @child.collection = @parent
        @child.save!
      end
      
      after(:all) { ActiveFedora::Base.delete_all } 
      subject(:child) { @child } 

      its(:collection) { should eq @parent }
      its(:community)  { should be nil } 
    end

    context "With parent community" do 
      before(:all) do 
        @parent = Community.new(:depositor => "Will") ; @parent.save! 
        @child = Collection.new(:depositor => "Will")
        @child.community = @parent 
        @child.save! 
      end
      
      after(:all) { ActiveFedora::Base.delete_all }
      subject(:child) { @child }

      its(:collection) { should be nil } 
      its(:community)  { should eq @parent } 
    end
  end

  describe "Queries" do 
    before(:all) do 
      @ancestor = Collection.new()
      @ancestor.depositor = "Will" 
      @ancestor.save!

      @child_col = Collection.new()
      @child_col.depositor = "Will" 
      @child_col.collection = @ancestor 
      @child_col.save! 

      @child_file = CoreFile.new()
      @child_file.depositor  = "Will" 
      @child_file.collection = @ancestor 
      @child_file.save!

      @descendent_kol = Collection.new()
      @descendent_kol.depositor = "Will" 
      @descendent_kol.collection = @child_col 
      @descendent_kol.save!

      @descendent_file = CoreFile.new()
      @descendent_file.depositor  = "Will" 
      @descendent_file.collection = @descendent_kol
      @descendent_file.save!

      @random_file = CoreFile.new()
      @random_file.depositor = "Will" 
      @random_file.save! 

      @random_kol  = Collection.new()
      @random_kol.depositor = "Will" 
      @random_kol.save!
    end

    it "can find children" do 
      expect(@ancestor.children).to match_array [@child_col, @child_file] 
    end

    it "returns an empty array when no children exist" do 
      expect(@random_kol.children).to match_array [] 
    end

    it "can find children who are records" do 
      expect(@ancestor.records).to match_array [@child_file]
    end

    it "can find children who are collections" do 
      expect(@ancestor.collections).to match_array [@child_col]
    end

    it "can find all descendents" do 
      expected = [@child_col, @child_file, @descendent_file, @descendent_kol]
      expect(@ancestor.descendents).to match_array expected 
    end

    it "can find all descendents who are records" do
      expected = [@child_file, @descendent_file]
      expect(@ancestor.descendent_records).to match_array expected
    end 

    it "can find all descendents who are collections" do 
      expected = [@child_col, @descendent_kol]
      expect(@ancestor.descendent_collections).to match_array expected
    end

    after(:all) do 
      ActiveFedora::Base.delete_all
    end
  end

  it_behaves_like "A Properties Delegator"
  it_behaves_like "a paranoid rights validator"
end
