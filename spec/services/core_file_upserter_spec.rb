require "spec_helper" 

describe CoreFileUpserter do 
  include FileHelpers

  describe "#update_metadata!" do
    before(:all) do 
      @params = { 
        :depositor => "tapas@neu.edu",
        :access => "public",
        :collection_did => "111",
        :file_type => "otherography",
      }

      upserter = CoreFileUpserter.new @params
      upserter.mods_path = fixture_file "mods.xml" 
      upserter.core_file = @core = CoreFile.new
      upserter.update_metadata!
      @core.reload
    end

    after(:all) { @core.delete } 

    it "sets the depositor equal to params[:depositor]" do 
      expect(@core.depositor).to eq @params[:depositor]
    end

    it "sets the drupal access level equal to params[:access]" do 
      expect(@core.drupal_access).to eq @params[:access] 
    end

    it "assigns the object to the phantom collection when no collection" \
      "with params[:collection_did] exists" do 
      pid = Rails.configuration.phantom_collection_pid
      expect(@core.collection.pid).to eq pid
    end

    # This test relies on usage of the mods.xml file
    it "assigns the metadata from the mods_path field to the mods record" do 
      expect(@core.mods.title.first).to eq "Test X, private"
    end
    
    it "writes the object's did to the MODS record" do 
      expect(@core.did).to eq @params[:did] 
    end

    it "writes the object's file type" do 
      expect(@core.otherography_for.first).to eq Collection.phantom_collection
    end
  end

  describe "#update_html_file!" do 
    context "when creating a teibp file" do 
      before(:all) do 
        u = CoreFileUpserter.new({})
        u.core_file = @core = FactoryGirl.create(:core_file)
        u.teibp_path = fixture_file "teibp.html" 
        u.update_html_file!("teibp")
      end

      it "creates the teibp html object" do 
        expect(@core.teibp).not_to be nil 
      end

      it "assigns the teibp file content to it" do 
        content = File.read fixture_file "teibp.html"
        expect(@core.teibp.content.content).to eq content
      end
    end

    context "when creating a tapas_generic file" do 
      before(:all) do 
        u = CoreFileUpserter.new({})
        u.core_file = @core = FactoryGirl.create(:core_file) 
        u.tapas_generic_path = fixture_file "tapas_generic.html" 
        u.update_html_file!("tapas_generic") 
      end

      it "creates the tapas_generic html object" do 
        expect(@core.tapas_generic).not_to be nil 
      end

      it "assigns the tapas_generic content to it" do 
        content = File.read fixture_file "tapas_generic.html" 
        expect(@core.tapas_generic.content.content).to eq content 
      end
    end
  end

  describe "#update_xml_file!" do
    context "when creating a tfc file" do 
      before(:all) do 
        u = CoreFileUpserter.new({})
        u.tfc_path = fixture_file "tei.xml"
        u.core_file = @core = FactoryGirl.create(:core_file)
        u.update_xml_file!(u.tfc_path, :tfc)
      end

      let(:tfc) { @core.reload.tfc.first }
      after(:all) { @core.delete }

      it "creates the tfc file" do
        expect(tfc).not_to be nil 
      end

      it "loads the file content into the content datastream" do 
        expect(tfc.content.content).to eq File.read(fixture_file("tei.xml"))
      end

      it "asserts that the content object is the tfc for the core record" do 
        expect(tfc.tfc_for.first).to eq @core 
        expect(tfc.tfc_for.size).to eq 1
        expect(tfc.canonical?).to be false
      end
    end

    context "when creating a tei file" do 
      before(:all) do 
        u = CoreFileUpserter.new({})
        u.core_file = @core = FactoryGirl.create(:core_file)
        u.tei_path = fixture_file "tei.xml" 
        u.update_xml_file!(u.tei_path, :tei) 
      end

      let(:tei) { @core.reload.canonical_object } 
      after(:all) { @core.delete }

      it "creates the tei file" do 
        expect(tei).not_to be nil 
        expect(tei.class).to eq TEIFile 
      end

      it "loads the file content into the content datastream" do 
        expect(tei.content.content).to eq File.read(fixture_file("tei.xml"))
      end

      it "asserts that the content object is the canonical record for the" \
        " core file" do 
        expect(tei.canonical?).to be true
        expect(tei.tfc_for.size).to eq 0 
      end
    end

    context "when updating an xml file" do 
      before(:all) do 
        u = CoreFileUpserter.new({})
        u.core_file = @core = FactoryGirl.create(:core_file)
        u.tei_path = fixture_file "tei.xml" 

        @tei = TEIFile.create(:depositor => @core.depositor)
        @tei.canonize
        @tei.add_file(File.read(fixture_file("tei.xml")), "content", "tei.xml") 
        @tei.core_file = @core 
        @tei.save!

        u.update_xml_file!(u.tei_path, :tei)
      end

      after(:all) { @core.delete }

      it "doesn't create a new content version for the same file" do 
        expect(@tei.content.versions.length).to eq 1 
      end

      it "doesn't create a new TEIFile object" do 
        expect(@core.content_objects(:raw).count).to eq 1 
      end
    end
  end

  describe "#update_support_files!" do 
    before(:all) do 
      u = CoreFileUpserter.new({})
      u.core_file = @core = FactoryGirl.create(:core_file)
      u.support_file_paths = [fixture_file("image.jpg"), 
        fixture_file("other_image.jpg")]

      tei = TEIFile.create(:depositor => "system") 
      tei.core_file = @core 
      tei.canonize
      tei.save!

      imf = ImageMasterFile.create(:depositor => "system") 
      imf.core_file = @core 
      imf.save!
      u.update_support_files!
      @core.reload
    end

    after(:all) { @core.delete }

    it "deletes preexisting image support files" do 
      expect(@core.content_objects(:raw).length).to eq 3 
    end

    it "does not delete TEIFile objects" do 
      expect(@core.canonical_object).not_to be nil 
    end

    it "writes the content for each support file" do 
      content_objects = @core.content_objects
      labels = %w(image.jpg other_image.jpg)

      content_objects.each do |content| 
        if content.instance_of? ImageMasterFile 
          expect(labels).to include content.content.label
          expect(content.content.content.size).not_to eq 0
        end
      end
    end
  end
end
