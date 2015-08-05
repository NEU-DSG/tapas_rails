require 'spec_helper'

shared_examples_for 'InlineThumbnails' do 
  include FileHelpers

  let(:object) do 
    symbol = described_class.to_s.downcase.to_sym
    FactoryGirl.create symbol
  end

  let(:thumb) { fixture_file('image.jpg') }

  it 'can add an object by filepath' do 
    object.add_thumbnail(:filepath => thumb)
    expect(object.thumbnail_1.content).to eq File.read(thumb)
    expect(object.thumbnail_1.label).to eq 'image.jpg'
    expect(object.thumbnail_list).to eq [object.download_path('thumbnail_1')]
  end

  it 'can add an object by name and blob' do 
    blob = File.read(thumb)
    object.add_thumbnail(:name => 'a.png', :content => blob)
    expect(object.thumbnail_1.content).to eq blob
    expect(object.thumbnail_1.label).to eq 'a.png'
    expect(object.thumbnail_list).to eq [object.download_path('thumbnail_1')]
  end
end
