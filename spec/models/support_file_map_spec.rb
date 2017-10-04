require 'spec_helper' 

describe SupportFileMap do 
  let(:core_file) { FactoryGirl.create :core_file } 
  let(:collection) { FactoryGirl.create :collection } 
  let(:community) { FactoryGirl.create :community }

  after(:each) { ActiveFedora::Base.delete_all }

  describe "#download_url" do 

    it "creates a download url based on the given content file object" do 
      x = SupportFileMap.new(nil)
      img = FactoryGirl.create :image_master_file

      expected_url = "http://railsapi.localhost:8080/downloads/#{img.pid}/?datastream_id=content"
      expect(x.download_url img).to eq expected_url
    end
  end

  describe '.build_map' do
    after(:all) { ActiveFedora::Base.delete_all }

    def attach_ography(ography, type, collection)
      core_file = FactoryGirl.create :core_file

      assignment = :"#{type}_for=" 
      filename = "#{type}.xml"

      ography.canonize 
      ography.add_file('<xml>x</xml>', 'content', filename)
      ography.core_file = core_file 
      ography.save! 

      core_file.send(assignment, [collection])
      core_file.save! 
    end
      
    def attach_page_image(page_image, filename) 
      page_image.page_image_for << @core_file
      page_image.add_file('test_content', 'content', filename)
      page_image.save! 
    end


    before(:all) do 
      @core_file   = FactoryGirl.create :core_file
      @collection  = FactoryGirl.create :collection
      @collection2 = FactoryGirl.create :collection

      @core_file.collections = [@collection, @collection2]
      @core_file.save!

      # Create three unique image files at the file scope
      @one, @two, @three = FactoryGirl.create_list(:image_master_file, 3) 

      # Create @three unique xml files at the collection
      @four, @five, @six = FactoryGirl.create_list(:tei_file, 3)

      # Create an image file at the collection scope that will conflict with @two
      @seven = FactoryGirl.create :image_master_file

      attach_page_image(@one, 'file_one.jpeg')
      attach_page_image(@two, 'file_two.png') 
      attach_page_image(@three, 'file_three.jpg') 

      attach_ography(@four, 'personography', @collection)
      attach_ography(@five, 'otherography', @collection) 
      attach_ography(@six, 'bibliography', @collection2)

      attach_ography(@seven, 'otherography', @collection2)
      @seven.add_file('test_content', 'content', 'file_two.png') 
      @seven.save!

      @map = SupportFileMap.build_map(@core_file)
    end

    it "saves all file level results to the files scope" do 
      file_scope = @map.result[:file]
      expect(file_scope['file_one.jpeg']).to eq @map.download_url @one
      expect(file_scope['file_two.png']).to eq @map.download_url @two 
      expect(file_scope['file_three.jpg']).to eq @map.download_url @three 
    end

    it "saves all collection level results to the collection scope" do 
      coll_scope = @map.result[:collection]
      expect(coll_scope['personography.xml']).to eq @map.download_url @four
      expect(coll_scope['otherography.xml']).to eq @map.download_url @five 
      expect(coll_scope['bibliography.xml']).to eq @map.download_url @six 
      expect(coll_scope['file_two.png']).to eq @map.download_url @seven
    end

    it "gives precedence to file scope level lookup" do 
      expect(@map.get_url 'file_two.png').to eq @map.download_url @two
    end

    it "returns nil on lookup for nonexistent filenames" do 
      expect(@map.get_url 'dogbert_speaks.wav').to be nil
    end
  end
end
