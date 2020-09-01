# require 'spec_helper'

# describe Content::UpsertThumbnail do
#   include FileHelpers

#   let(:core_file) { FactoryBot.create(:core_file) }
#   let(:thumbnail) { FactoryBot.create(:image_thumbnail_file) }

#   context 'with no previous thumbnail file' do

#     after(:all) { ActiveFedora::Base.delete_all }

#     it 'creates the thumbnail file' do
#       Content::UpsertThumbnail.execute(core_file, fixture_file('image.jpg'))
#       core_file.reload
#       expect(core_file.thumbnail).not_to be nil
#       thumb = core_file.thumbnail
#       expect(thumb.thumbnail_1.label).to eq 'image.jpg'
#       dl_path = thumb.download_path('thumbnail_1')
#       expect(core_file.thumbnails).to eq [dl_path]
#     end
#   end

#   context 'with a previous thumbnail' do

#     after(:all) { ActiveFedora::Base.delete_all }

#     it 'updates the existing thumbnail' do
#       new_thumb = fixture_file('other_image.jpg')
#       Content::UpsertThumbnail.execute(core_file, fixture_file('image.jpg'))
#       Content::UpsertThumbnail.execute(core_file, fixture_file(new_thumb))

#       core_file.reload
#       expect(core_file.thumbnail).not_to be nil

#       count = core_file.content_objects(:raw).count do |content_object|
#         content_object['active_fedora_model_ssi'] = 'ImageThumbnailFile'
#       end

#       expect(count).to eq 1
#     end
#   end
# end
