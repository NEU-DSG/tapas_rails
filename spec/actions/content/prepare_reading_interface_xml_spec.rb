# require 'spec_helper'

# describe PrepareReadingInterfaceXML do
#   include FileHelpers

#   describe ".execute" do
#     after(:all) { ActiveFedora::Base.delete_all }

#     def build_and_attach_ography(type_assignment, collection, filename)
#       core = FactoryBot.create :core_file
#       xml  = FactoryBot.create :tei_file
#       xml.core_file = core
#       xml.canonize
#       xml.add_file('<xml />', 'content', filename)
#       xml.save!

#       core.collections = [collection]
#       core.send(type_assignment, [collection])
#       core.save!

#       xml
#     end

#     before(:all) do
#       @core_file = FactoryBot.create :core_file
#       @community = FactoryBot.create :community
#       @collection = FactoryBot.create :collection

#       @core_file.collections << @collection
#       @collection.community = @community

#       # Create page images
#       @pimg1, @pimg2 = FactoryBot.create_list(:image_master_file, 2)
#       @pimg1.page_image_for << @core_file
#       @pimg1.add_file('picture', 'content', 'image_one.jpg')
#       @pimg2.page_image_for << @core_file
#       @pimg2.add_file('picture', 'content', 'image_two.jpg')

#       @xml  = Nokogiri::XML(File.read(fixture_file 'tei_with_refs.xml'))

#       @biblio = build_and_attach_ography(:bibliography_for=,
#                                          @collection, 'bibliography.xml')
#       @other = build_and_attach_ography(:otherography_for=,
#                                         @collection, 'otherography.xml')
#       @place = build_and_attach_ography(:placeography_for=,
#                                         @collection, 'placeography.xml')

#       @core_file.save!
#       @community.save!
#       @collection.save!
#       @pimg1.save!
#       @pimg2.save!

#       @xml = PrepareReadingInterfaceXML.execute(@core_file, @xml)
#     end

#     let(:map) { SupportFileMap.new(nil) }

#     let(:tei_namespace) { { 'tei' => 'http://www.tei-c.org/ns/1.0' } }

#     it 'rewrites the second url in the first name element' do
#       expected = "ftp://example.net#billy #{map.download_url(@place)}#ted"
#       actual = @xml.xpath('//tei:name/@ref', tei_namespace).to_s
#       expect(actual).to eq expected
#     end

#     it 'ignores the absolute url in the first graphic element' do
#       expected = 'http://absolute.url'
#       actual = @xml.xpath('//tei:graphic[1]/@url', tei_namespace).to_s
#       expect(actual).to eq expected
#     end

#     it 'rewrites the relative url in the first graphic element' do
#       expected = map.download_url(@pimg1)
#       actual = @xml.xpath('//tei:graphic[2]/@url', tei_namespace).to_s
#       expect(actual).to eq expected
#     end

#     it 'rewrites the first url in the ref on the first note element' do
#       expected = "#{map.download_url(@other)}#test http://www.google.com"
#       actual = @xml.xpath('//tei:note/@ref', tei_namespace).to_s
#       expect(actual).to eq expected
#     end
#   end
# end
