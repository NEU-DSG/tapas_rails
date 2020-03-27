require 'spec_helper'

describe CoreFile do 
  describe "Parent collections" do 
    before(:all) do 
      @parent = Collection.create(depositor: "Will") 
      @core   = CoreFile.create(depositor: "Will", collection: @parent)
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    subject(:core) { @core } 

    its(:collection) { should eq @parent } 
  end

  describe "Content Objects" do 
    before :all do 
      @core = CoreFile.create(depositor: "Will") 

      @wigwum  = Wigwum.create(core_file: @core)
      
      @wumpus  = Wumpus.new(core_file: @core)
      @wumpus.canonize
      @wumpus.save! 

      @wigwum2 = Wigwum.create 
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    it "can be found in various ways" do 
      expect(@core.content_objects).to match_array [@wigwum, @wumpus]
      expect(@core.canonical_object).to eq @wumpus
    end

    it "are destroyed on core record destruction" do 
      wigwum_pid = @wigwum.pid 
      wumpus_pid = @wumpus.pid

      @core.destroy 

      expect(Wumpus.exists?(wumpus_pid)).to be false 
      expect(Wigwum.exists?(wigwum_pid)).to be false 
    end
  end

  it_behaves_like "A Properties Delegator"
  it_behaves_like "a paranoid rights validator"
end
