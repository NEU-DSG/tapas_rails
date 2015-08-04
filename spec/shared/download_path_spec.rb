require 'spec_helper'

shared_examples_for 'DownloadPath' do 
  let(:model) { described_class.new }
  let(:url) { Settings['base_url'] }

  it 'generates a full download path to the content datastream by default' do
    full_url = "#{url}/downloads/#{model.pid}?datastream_id=content"
    expect(model.download_path).to eq full_url 
  end

  it 'can take a different datastream id as an optional argument' do 
    full_url = "#{url}/downloads/#{model.pid}?datastream_id=thumbnail_1"
    expect(model.download_path 'thumbnail_1').to eq full_url
  end
end
