require 'spec_helper'

describe CoreFileCreatorService do 
  def copy_tei
    @original_path = "#{Rails.root}/spec/fixtures/files/tei.xml"
    @copy_path     = "#{Rails.root}/spec/fixtures/files/tei_copy.xml"

    FileUtils.cp(@original_path, @copy_path)
  end

  describe "A clean run" do 
    before(:all) do 
      copy_tei

      params = {}
      params[:depositor]     = "tapasguy@brown.edu"
      params[:node_id]       = "123"
      params[:collection_id] = "3017"
      params[:file]          = @copy_path

      # Instantiate the collection we expect to exist
      @collection = Collection.new
      @collection.nid       = "3017"
      @collection.depositor = "tapasguy@brown.edu"
      @collection.save!

      @core = CoreFileCreatorService.create_record(params)
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "returns a core file" do 
      expect(@core.class).to eq CoreFile 
    end

    it "assigns a depositor to the core file" do 
      expect(@core.depositor).to eq "tapasguy@brown.edu"
    end

    it "assigns a nid to the core file" do 
      expect(@core.nid).to eq "123"
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
      expected = File.read(@original_path)
      expect(actual).to eq expected 
    end

    it "deletes the file at params[:file] from the filesystem." do 
      expect(File.exists? @copy_path).to be false 
    end
  end

  describe "A run where the collection doesn't exist" do 
    before(:all) do
      copy_tei  
      params = {}
      params[:depositor]     = "tapasguy@brown.edu"
      params[:node_id]       = "8873"
      params[:collection_id] = "invalid"
      params[:file]          = @copy_path
      
      @core = CoreFileCreatorService.create_record(params)
    end

    after(:all) { ActiveFedora::Base.delete_all }

    it "adds the TEI record to the phantom collection" do 
      expect(@core.collection.pid).to eq Rails.configuration.phantom_collection_pid
    end
  end

  describe "A run that errors out", :type => :mailer do 
    before(:all) { copy_tei } 
    after(:all)  { ActiveFedora::Base.delete_all }

    it "persists no objects, deletes the TEI File, and triggers an exception notification." do
      params = {
        :depositor     => "tapasguy@brown.edu",
        :node_id       => "1919191",
        :collection_id => "valid",
        :file          => @copy_path,
      }
      
      # Ensure that file creation fails near the very end
      TEIFile.any_instance.stub(:save!).and_raise(RuntimeError)

      expect { CoreFileCreatorService.create_record(params) }.to raise_error(RuntimeError)

      expect(CoreFile.count).to eq 0
      expect(File.exists? @copy_path).to be false

      # Validate the email
      expect(ActionMailer::Base.deliveries.length).to eq 1
      mail = ActionMailer::Base.deliveries.first 
      expect(mail.subject).to include "[Tapas Rails Notifier TEST]"
    end
  end
end
