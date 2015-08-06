require "spec_helper" 

describe UpsertCoreFile do 
  include FileHelpers

  describe '#update_associations' do 
    context 'on create (:collection_dids && :file_type mandatory)' do 
      before(:all) do 
        c_one, c_two, c_three = FactoryGirl.create_list(:collection, 3)
        did = SecureRandom.uuid
        @params = { 
          :file_types => ['otherography', 'placeography', 'odd_file'],
          :collection_dids => [c_one.did, c_two.did, c_three.did]
        }

        upserter = UpsertCoreFile.new @params
        @core_file = CoreFile.create(:did => did, :depositor => 'test')
        upserter.core_file = @core_file
        upserter.update_associations!
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
        @old_collections = FactoryGirl.create_list(:collection, 2)
        @core_file = FactoryGirl.create :core_file
        @core_file.collections = @old_collections
        @core_file.bibliography_for = @old_collections
        @core_file.orgography_for = @old_collections
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
        @core_file.collections = @old_collections
        @core_file.bibliography_for = @old_collections
        @core_file.placeography_for = @old_collections
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

  describe '#upsert' do 
    before(:all) do 
      @zip = copy_fixture('all_files.zip', "zip_copy.zip")
      @tei = copy_fixture('tei.xml', 'tei_copy.xml')

      @collections = FactoryGirl.create_list(:collection, 3)

      # Make all the collections private
      @collections.each do |collection|
        collection.drupal_access = 'private'
        collection.save!
      end

      @params = {
        :did => SecureRandom.uuid, 
        :collection_dids => @collections.map { |x| x.did },
        :file_types => [:personography, :placeography], 
        :depositor => "William Jackson",
        :support_files => @zip,
        :display_author => 'Wallace & Grommit', 
        :display_contributors => ['A', 'B', 'C'],
        :tei => @tei
      }

      UpsertCoreFile.upsert(@params)

      @core_file = CoreFile.find_by_did(@params[:did])
    end

    it 'creates the CoreFile and associates it with its drupal id' do 
      expect(@core_file).not_to be nil 
    end

    it 'writes the pid of the object to the MODS datastream' do 
      expect(@core_file.mods.identifier.first).to eq @core_file.pid
    end

    it 'attaches a TEIFile object with the expected content' do 
      tei = @core_file.canonical_object
      expect(tei.content.content).to eq File.read(fixture_file('tei.xml'))
    end

    it 'adds a ImageThumbnailFile object with the expected content' do 
      thumb = @core_file.thumbnail
      expect(thumb.thumbnail_1.label).to eq 'thumbnail.jpg'
      expect(thumb.thumbnail_1.content.size).not_to eq 0 
    end

    it 'adds PageImage files with content' do 
      page_images = @core_file.page_images
      expect(page_images.count).to eq 3
      expect(page_images.all? { |x| x.content.content.present? }).to be true
    end

    it 'generates a teibp reading interface object' do 
      teibp = @core_file.teibp 
      expect(teibp.content.label).to eq 'teibp.xhtml' 
    end

    it 'generates a tapas-generic reading interface object' do 
      tapas_generic = @core_file.tapas_generic
      expect(tapas_generic.content.label).to eq 'tapas-generic.xhtml' 
    end

    it 'assigns the object a drupal_access level' do 
      expect(@core_file.drupal_access).to eq 'private'
    end

    it 'assigns a depositor to the core file' do 
      expect(@core_file.depositor).to eq @params[:depositor]
    end

    it 'makes the CoreFile a member of the specified collections' do 
      expect(@core_file.collections).to eq @collections
    end

    it 'makes the CoreFile each type of specified ography' do 
      expect(@core_file.placeography_for).to eq @collections
      expect(@core_file.personography_for).to eq @collections
    end
  end
end
