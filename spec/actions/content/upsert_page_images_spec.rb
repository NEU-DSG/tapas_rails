require 'spec_helper' 

describe Content::UpsertPageImages do
  include FileHelpers 

  let(:core_file) { FactoryGirl.create(:core_file) }

  it 'raises an error and deletes all files when invalid files are passed' do 
    imgs = [fixture_file('tei.xml')]
    e = Exceptions::InvalidZipError
    action = Content::UpsertPageImages
    expect { action.execute(core_file, imgs) }.to raise_error e
  end

  context 'with preexisting image files' do 
    before(:all) do 
      @file = fixture_file('image.jpg')
      @file_two = fixture_file('other_image.jpg')

      @fname = Pathname.new(@file).basename.to_s
      @fname_two = Pathname.new(@file_two).basename.to_s 

      @core_file = FactoryGirl.create(:core_file) 

      @old_image = ImageMasterFile.create
      @old_image.page_image_for << @core_file 
      @old_image.core_file = @core_file 
      @old_image.save! 

      @old_image_pid = @old_image.pid

      Content::UpsertPageImages.execute(@core_file, [@file, @file_two])
      @core_file.reload
    end

    after(:all) { @core_file.destroy }

    it 'purges the old images associated with a core file' do 
      expect(ImageMasterFile.exists?(@old_image_pid)).to be false
      expect(@core_file.page_images.count).to eq 2
    end

    it 'adds content to all page image objects' do 
      @core_file.page_images.each do |page_image| 
        expect(page_image.content.content.size).not_to eq 0 
        expect(page_image.filename).not_to eq ''
      end
    end
  end
end
