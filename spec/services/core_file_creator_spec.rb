require 'spec_helper'

describe CoreFileCreator do 
  include FileHelpers
  def params
    { :depositor => "tapasguy@brown.edu", 
      :nid => "123",
      :access => "public",
      :collection => "3017",
      :file => fixture_file("tei_copy.xml") }
  end

  describe "A clean run" do 
    before(:all) do 
      copy_fixture("tei.xml", "tei_copy.xml")
      # Instantiate the collection we expect to exist
      @collection = Collection.new
      @collection.nid = "3017"
      @collection.depositor = "tapasguy@brown.edu"
      @collection.save!

      @core = CoreFileCreator.create_record(params)
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "returns a core file" do 
      expect(@core.class).to eq CoreFile 
    end

    it "assigns a depositor to the core file" do 
      expect(@core.depositor).to eq params[:depositor]
    end

    it "sets the drupal access level of the object" do 
      expect(@core.drupal_access).to eq params[:access]
    end

    it "assigns a nid to the core file" do 
      expect(@core.nid).to eq params[:nid]
    end

    it "stores the nid of its parent as a distinct property" do 
      expect(@core.og_reference).to eq params[:collection]
    end
    
    it "assigns the core file to the right parent collection" do 
      expect(@core.collection.pid).to eq @collection.pid 
    end

    it "makes the core file private" do 
      expect(@core.mass_permissions).to eq "private" 
    end

    it "instantiates the required tei_file object and makes it canonical" do 
      expect(@core.canonical_object(:return_as => :models).class).to eq TEIFile
    end

    it "writes the expected content to the TEIFile object" do 
      actual   = @core.canonical_object(:return_as => :models).content.content 
      expected = File.read(fixture_file("tei.xml"))
      expect(actual).to eq expected 
    end

    it "deletes the file at params[:file] from the filesystem." do 
      expect(File.exists?(fixture_file("tei_copy.xml"))).to be false 
    end
  end

  describe "A run where the collection doesn't exist" do 
    before(:all) do
      copy_fixture("tei.xml", "tei_copy.xml")
      @core = CoreFileCreator.create_record(params)
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "adds the TEI record to the phantom collection" do 
      expect(@core.collection.pid).to eq Rails.configuration.phantom_collection_pid
    end

    it "records the nid of its expected parent." do 
      expect(@core.og_reference).to eq params[:collection]
    end
  end

  describe "A run that errors out", :type => :mailer do 
    before(:all) { copy_fixture("tei.xml", "tei_copy.xml") } 
    after(:all)  { ActiveFedora::Base.delete_all }

    it "persists no objects, deletes the TEI File, and triggers an exception notification." do
      # Ensure that file creation fails near the very end
      TEIFile.any_instance.stub(:save!).and_raise(RuntimeError)

      expect { CoreFileCreator.create_record(params) }.to raise_error(RuntimeError)

      expect(CoreFile.count).to eq 0
      expect(File.exists?(fixture_file("tei_copy.xml"))).to be false

      # Validate the email
      expect(ActionMailer::Base.deliveries.length).to eq 1
      mail = ActionMailer::Base.deliveries.first 
      expect(mail.subject).to include "[Tapas Rails Notifier TEST]"
    end
  end
end
