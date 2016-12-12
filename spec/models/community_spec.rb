require 'spec_helper'

describe Community do
  include FileHelpers
  after(:each) { ActiveFedora::Base.delete_all }

  it "can create the root community when it doesn't exist" do
    expect{ Community.root_community }.to change{ Community.count }.from(0).to(1)
    expect(Community.root_community.pid).to eq Rails.configuration.tap_root
  end

  it "can look up the root community when it already exists" do
    Community.root_community
    expect{ Community.root_community }.not_to change{ Community.count }.from(1)
    expect(Community.root_community.pid).to eq Rails.configuration.tap_root
  end

  describe '#as_json' do
    after(:each) { ActiveFedora::Base.delete_all }

    it 'returns a valueless hash for empty Communities' do
      result = Community.new.as_json
      keys = %i(members depositor access thumbnail title description)
      expect(keys.all? { |k| result.has_key?(k) }).to be true
      expect(result.all? { |k, v| v.blank? }).to be true
    end

    it 'populates values appropriately where they exist' do
      community = FactoryGirl.create :community
      community.mods.title = 'A Test Community'
      community.mods.abstract = 'Community created for testing #as_json'
      community.drupal_access = 'public'
      community.depositor = 'Will Jackson'
      community.add_thumbnail(:filepath => fixture_file('image.jpg'))
      community.project_members = %w(Peter Paul Mary)

      result = community.as_json
      expect(result[:title]).to eq 'A Test Community'
      expect(result[:description]).to eq 'Community created for testing #as_json'
      expect(result[:access]).to eq 'public'
      expect(result[:depositor]).to eq 'Will Jackson'
      expect(result[:thumbnail]).to eq 'image.jpg'
      expect(result[:members]).to eq %w(Peter Paul Mary)
    end
  end

  it_behaves_like 'InlineThumbnails'
end
