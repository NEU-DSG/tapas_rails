require 'spec_helper'

shared_examples_for 'InlineThumbnails' do
  include FileHelpers

  let(:object) do
    symbol = described_class.to_s.downcase.to_sym
    FactoryBot.create symbol
  end

  let(:thumb) { fixture_file('image.jpg') }

  it 'can add an object by filepath' do
    object.add_thumbnail(io: File.open(thumb), filename: 'image.jpg')
    expect(object.thumbnail.filename).to eq 'image.jpg'
  end
end
