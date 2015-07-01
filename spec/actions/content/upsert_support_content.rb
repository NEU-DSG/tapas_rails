require 'spec_helper' 

describe UpsertSupportContent do 
  include FileHelpers 

  context '#upsert!' do 
    it 'raises an error and deletes all files when invalid files are passed' do 
      cf = FactoryGirl.create(:core_file)
      imgs = [copy_fixture('tei.xml', "#{SecureRandom.hex}.xml")]

      expect { UpsertSupportContent.upsert!(cf, imgs) }.
        to raise_error Exceptions::InvalidZipError
      expect(File.exists? imgs.first).to be false
    end

    context 'with preexisting image files' do 
      before(:all) do 
        @file = copy_fixture('image.jpg', "#{SecureRandom.hex}.jpg")
        @file_two = copy_fixture('other_image.jpg', "#{SecureRandom.hex}.jpg")

        @fname = Pathname.new(@file).basename.to_s
        @fname_two = Pathname.new(@file_two).basename.to_s 

        @core_file = FactoryGirl.create(:core_file) 

        @old_image = ImageMasterFile.create
        @old_image.page_image_for << @core_file 
        @old_image.core_file = @core_file 
        @old_image.save! 

        @old_image_pid = @old_image.pid

        UpsertSupportContent.upsert!(@core_file, [@file, @file_two])
        @core_file.reload
      end

      after(:all) { @core_file.destroy }

      it 'purges the old images associated with a core file' do 
        expect(ImageMasterFile.exists?(@old_image_pid)).to be false
        expect(@core_file.page_images.count).to eq 2
      end

      it 'deletes the files' do 
        expect(File.exists? @file).to be false 
        expect(File.exists? @file_two).to be false
      end

      it 'adds content to all page image objects' do 
        @core_file.page_images.each do |page_image| 
          expect(page_image.content.content.size).not_to eq 0 
          expect(page_image.filename).not_to eq ''
        end
      end
    end
  end
end
