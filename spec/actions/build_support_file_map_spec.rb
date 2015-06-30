require 'spec_helper' 

describe BuildSupportFileMap do 
  let(:core_file) { FactoryGirl.create :core_file } 
  let(:collection) { FactoryGirl.create :collection } 
  let(:community) { FactoryGirl.create :community }

  after(:each) { ActiveFedora::Base.delete_all }

  describe "#download_url" do 

    it "creates a download url based on the given content file object" do 
      x = BuildSupportFileMap.new(nil, nil) 
      img = FactoryGirl.create :image_master_file

      expected_url = "rails_api.localhost:8080/downloads/#{img.pid}/?datastream_id=content"
      expect(x.download_url img).to eq expected_url
    end
  end

  describe '#create_file_level_map' do 
    it "creates a mapping of page image filenames to content urls" do 
      one, two, three = FactoryGirl.create_list(:image_master_file, 3) 

      one.page_image_for << core_file
      one.add_file('test_content', 'content', 'file_one.jpeg')
      two.page_image_for << core_file 
      two.add_file('test_content', 'content', 'file_two.png')
      three.page_image_for << core_file 
      three.add_file('test_content', 'content', 'file_three.jpg')
      one.save! ; two.save! ; three.save! 

      b = BuildSupportFileMap.new(core_file, community) 

      b.create_file_level_map
      expect(b.result[:file_level]['file_one.jpeg']).to eq b.download_url one
      expect(b.result[:file_level]['file_two.png']).to eq b.download_url two 
      expect(b.result[:file_level]['file_three.jpg']).to eq b.download_url three
    end
  end

  describe '#create_project_level_map' do 

  end
end
