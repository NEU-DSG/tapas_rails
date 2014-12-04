require 'spec_helper'

describe FileRevisionJob do 
  include FileHelpers

  describe "A clean run" do 
    before(:all) do 
      @core = FactoryGirl.create(:core_file)

      @tei = TEIFile.new
      @tei.depositor = "SYSTEM"
      @tei.canonize
      @old_filepath = "#{Rails.root}/spec/fixtures/files/tei.xml"
      @old_filename = "tei.xml"
      @tei.add_file(File.read(@old_filepath), "content", @old_filename)
      @tei.save! ; @tei.core_file = @core ; @tei.save!

      Resque.inline = true
      @filepath = copy_fixture("tei_full_metadata.xml", "tfm_copy.xml")
      @filename = "tfm_copy.xml"
      job = FileRevisionJob.new(@core.nid, @filepath, @filename) 
      job.run
      Resque.inline = false

      @core.reload ; @tei.reload
    end

    after(:all) { @core.destroy }

    it "updates the content of the tei_file object" do 
      expect(@tei.content.content).not_to eq File.read(@old_filepath)
      # Since the copy of this is deleted by the job we have to check against
      # the original
      file = fixture_file("tei_full_metadata.xml")
      # @TODO -> Why does this think it isn't UTF-8?
      expect(@tei.content.content.force_encoding("UTF-8")).to eq File.read(file)
    end

    it "updates the version of the tei_file content datastream" do  
      expect(@tei.content.versionID).to eq "content.1"
    end

    it "sets the content datastream label to the original filename" do 
      expect(@tei.content.label).to eq @filename
    end

    it "keeps the previous revision" do 
      expect(@tei.content.versions.length).to eq 2
      old = @tei.content.versions.find { |version| version.versionID == "content.0" }

      expect(old.label).to eq @old_filename
      expect(old.content).to eq File.read(@old_filepath)
    end

    it "deletes the file" do 
      expect(File.exists? @filepath).to be false 
    end
  end

  describe "A run that errors out", :type => :mailer do 
    before(:all) do 
      @core = FactoryGirl.create(:core_file)

      @tei  = TEIFile.new
      @tei.depositor = "SYSTEM"
      @tei.canonize
      @tei.save! ; @tei.core_file = @core ; @tei.save!

      @fcopy = copy_fixture("tei.xml", "tei_copy.xml")
    end

    after(:all) { @core.destroy }

    it "raises an exception, doesn't persist changes to the tei_file" do 
      TEIFile.any_instance.stub(:save!).and_raise(RuntimeError)

      job = FileRevisionJob.new(@core.nid, @fcopy, "tei_copy.xml")

      expect(File.exists? @fcopy).to be true
      Resque.inline = true 
      expect { job.run }.to raise_error RuntimeError
      Resque.inline = false 
      
      expect(@tei.content.content).to be nil 
      expect(@tei.content.versions.length).to eq 0 
      expect(File.exists? @fcopy).to be false

      expect(ActionMailer::Base.deliveries.length).to eq 1 
    end
  end
end
