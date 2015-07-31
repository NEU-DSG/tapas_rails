require "spec_helper" 

describe UpsertCoreFile do 
  include FileHelpers

  describe '#update_associations' do 
    context 'on create (:collection_dids && :file_type mandatory)' do 
      before(:all) do 
        c_one, c_two, c_three = FactoryGirl.create_list(:collection, 3)
        did = SecureRandom.uuid
        @params = { 
          :file_types => ['otherography', 'placeography', 'odd_file_for'],
          :collection_dids => [c_one.did, c_two.did, c_three.did]
        }

        upserter = UpsertCoreFile.new @params
        @core_file = CoreFile.create(:did => did, :depositor => 'test')
        upserter.core_file = @core_file
        upserter.update_associations
        @core_file.reload
      end

      after(:all) { ActiveFedora::Base.delete_all }

      it 'updates the collections associated with the core_file' do 
        dids = @core_file.collections.map { |collection| collection.did }
        expect(dids).to match_array @params[:collection_dids]
      end

      it 'updates the otherography relationships' do
        dids = @core_file.otherography_for.map { |collection| collection.did }
        expect(dids).to match_array @params[:collection_dids]
      end

      it 'updates the placeography relationships' do 
        dids = @core_file.placeography_for.map { |collection| collection.did }
        expect(dids).to match_array @params[:collection_dids]
      end

      it 'updates the odd_file relationships' do 
        dids = @core_file.odd_file_for.map { |collection| collection.did }
        expect(dids).to match_array @params[:collection_dids]
      end
    end

    context 'on update with new :collection_dids && no :file_types' do 
      before(:all) do 
        old_collections = FactoryGirl.create_list(:collection, 2)
        @core_file = FactoryGirl.create :core_file
        @core_file.collections = old_collections
        @core_file.bibliography_for = old_collections
        @core_file.orgography_for = old_collections
        @core_file.save!

        @new_collections = FactoryGirl.create_list(:collection, 3)
        @new_dids = @new_collections.map { |collection| collection.did }
        @params = { 
          :collection_dids => @new_dids
        }
        upserter = UpsertCoreFile.new @params 
        upserter.core_file = @core_file 
        upserter.update_associations! 
        @core_file.reload
      end

      after(:all) { ActiveFedora::Base.delete_all }

      it 'updates the collections associated with the core_file' do 
        expect(@core_file.collections).to match_array @new_collections
      end

      it 'updates the previously defined bibliography relationship' do 
        expect(@core_file.bibliography_for).to match_array @new_collections
      end

      it 'updates the previously defined orgography relationship' do 
        expect(@core_file.orgography_for).to match_array @new_collections
      end

      it 'leaves all previously empty relationships empty' do 
        expect(@core_file.placeography_for).to be_empty
        expect(@core_file.odd_file_for).to be_empty
        expect(@core_file.otherography_for).to be_empty
        expect(@core_file.personography_for).to be_empty
      end
    end

    context 'on update with new :file_types && no :collection_dids' do 
      before(:all) do 
        @old_collections = FactoryGirl.create_list(:collection, 2)
        @core_file = FactoryGirl.create :core_file 
        @core_file.collections = old_collections
        @core_file.bibliography_for = old_collections
        @core_file.placeography_for = old_collections
        @core_file.save! 

        @params = { 
          :file_types => ['odd_file', 'otherography']
        }

        upserter = UpsertCoreFile.new @params 
        upserter.core_file = @core_file
        upserter.update_associations!
        @core_file.reload
      end

      after(:all) { ActiveFedora::Base.delete_all }

      it 'does not clear the .collections relationship' do 
        expect(@core_file.collections).to eq @old_collections
      end

      it 'clears the previously set bibliography relationship' do 
        expect(@core_file.bibliography_for).to be_empty 
      end

      it 'clears the previously set placeography relationship' do 
        expect(@core_file.placeography_for).to be_empty
      end

      it 'assigns the old collections to the odd_file_for relationship' do 
        expect(@core_file.odd_file_for).to eq @old_collections
      end

      it 'assigns the old collections to the otherography relationship' do 
        expect(@core_file.otherography_for).to eq @old_collections
      end
    end
  end

  describe "#update_metadata!" do
    before(:all) do 
      ActiveFedora::Base.delete_all

      @params = { 
        :depositor => "tapas@neu.edu",
        :access => "public",
        :collection_dids => ["111"],
        :file_type => "otherography",
      }

      @collection = FactoryGirl.create(:collection)
      @collection.did = @params[:collection_dids].first
      @collection.save!

      # Ography assignment depends on a given TEI File 
      # being able to determine which project it belongs to, 
      # hence bothering to create a community here.
      @community = FactoryGirl.create(:community)
      @collection.community = @community
      @collection.save!

      upserter = UpsertCoreFile.new @params
      upserter.core_file = @core = CoreFile.new
      upserter.update_metadata!
      @core.reload
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    it "sets the depositor equal to params[:depositor]" do 
      expect(@core.depositor).to eq @params[:depositor]
    end

    it "sets the drupal access level equal to params[:access]" do 
      expect(@core.drupal_access).to eq @params[:access] 
    end

    it "assigns the object to all collections listed in collection_dids" do 
      expect(@core.collections).to match_array [@collection]
    end

    it "sets og reference to the provided collection_dids" do 
      expect(@core.og_reference).to match_array @params[:collection_dids]
    end
    
    it "writes the object's did to the MODS record" do 
      expect(@core.did).to eq @params[:did] 
    end

    it "writes the object's file type" do 
      expect(@core.otherography_for.first.pid).to eq @community.pid
    end
  end
end
