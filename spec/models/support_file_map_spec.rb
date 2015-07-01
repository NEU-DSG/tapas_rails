require 'spec_helper' 

describe SupportFileMap do 
  let(:core_file) { FactoryGirl.create :core_file } 
  let(:collection) { FactoryGirl.create :collection } 
  let(:community) { FactoryGirl.create :community }

  after(:each) { ActiveFedora::Base.delete_all }

  describe "#download_url" do 

    it "creates a download url based on the given content file object" do 
      x = SupportFileMap.new(nil, nil) 
      img = FactoryGirl.create :image_master_file

      expected_url = "rails_api.localhost:8080/downloads/#{img.pid}/?datastream_id=content"
      expect(x.download_url img).to eq expected_url
    end
  end

  describe '.build_map' do
    after(:all) { ActiveFedora::Base.delete_all }

    def attach_ography(ography, type)
      core_file = FactoryGirl.create :core_file

      assignment = :"#{type}_for=" 
      filename = "#{type}.xml"

      ography.canonize 
      ography.add_file('<xml>x</xml>', 'content', filename)
      ography.core_file = core_file 
      ography.save! 

      core_file.send(assignment, [@community])
      core_file.save! 
    end
      
    def attach_page_image(page_image, filename) 
      page_image.page_image_for << @core_file
      page_image.add_file('test_content', 'content', filename)
      page_image.save! 
    end


    before(:all) do 
      @core_file = FactoryGirl.create :core_file
      @community = FactoryGirl.create :community

      # Create three unique image files at the file scope
      @one, @two, @three = FactoryGirl.create_list(:image_master_file, 3) 

      # Create @three unique xml files at the project scope
      @four, @five, @six = FactoryGirl.create_list(:tei_file, 3)

      # Create an image file at the project scope that will conflict with @two
      @seven = FactoryGirl.create :image_master_file

      attach_page_image(@one, 'file_one.jpeg')
      attach_page_image(@two, 'file_two.png') 
      attach_page_image(@three, 'file_three.jpg') 

      attach_ography(@four, 'personography') 
      attach_ography(@five, 'otherography') 
      attach_ography(@six, 'bibliography') 

      attach_ography(@seven, 'otherography')
      @seven.add_file('test_content', 'content', 'file_two.png') 
      @seven.save!

      @map = SupportFileMap.build_map(@core_file, @community)
    end

    it "saves all file level results to the files scope" do 
      file_scope = @map.result[:file]
      expect(file_scope['file_one.jpeg']).to eq @map.download_url @one
      expect(file_scope['file_two.png']).to eq @map.download_url @two 
      expect(file_scope['file_three.jpg']).to eq @map.download_url @three 
    end

    it "saves all project level results to the project scope" do 
      proj_scope = @map.result[:project] 
      expect(proj_scope['personography.xml']).to eq @map.download_url @four
      expect(proj_scope['otherography.xml']).to eq @map.download_url @five 
      expect(proj_scope['bibliography.xml']).to eq @map.download_url @six 
      expect(proj_scope['file_two.png']).to eq @map.download_url @seven
    end

    it "gives precedence to file scope level lookup" do 
      expect(@map.get_url 'file_two.png').to eq @map.download_url @two
    end

    it "returns nil on lookup for nonexistent filenames" do 
      expect(@map.get_url 'dogbert_speaks.wav').to be nil
    end
  end
end
