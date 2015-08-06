require 'spec_helper' 

describe UpsertCommunity do 
  include FileHelpers

  def params 
    { :did => '123',
      :depositor => '011',
      :description => 'This community is a test',
      :title => 'A sample community',
      :access => 'public', 
      :members => ['011', '023', '034'], 
      :thumbnail => fixture_file('image_copy.jpg'),
    }
  end

  subject(:community) { Community.find_by_did(params[:did]) }

  RSpec.shared_examples 'a metadata assigning operation' do 
    its('mods.title')     { should eq [params[:title]] } 
    its(:drupal_access)   { should eq params[:access] } 
    its(:mass_permissions) { should eq 'private' }
    its('mods.abstract')  { should eq [params[:description]] }
    its(:project_members) { should match_array params[:members] } 
  end

  RSpec.shared_examples 'a thumbnail updating operation' do 
    its('thumbnail_1.content') { should_not be nil } 
    its('thumbnail_1.label') { should eq 'image_copy.jpg' }

    it 'deletes the file' do 
      expect(File.exists?(fixture_file('image_copy.jpg'))).to be false
    end
  end

  context 'Create' do 
    before(:all)  do
      copy_fixture('image.jpg', 'image_copy.jpg')
      UpsertCommunity.upsert params
    end
    after(:all) { ActiveFedora::Base.delete_all } 

    it 'builds the requested community' do 
      expect(community.class).to eq Community 
    end

    it 'assigns the community as a child of the root community' do 
      expect(community.community.pid).to eq Community.root_community.pid
    end

    it_should_behave_like 'a metadata assigning operation'
    it_should_behave_like 'a thumbnail updating operation'
  end

  context 'Update' do 
    before(:all) do 
      copy_fixture('image.jpg', 'image_copy.jpg')
      community = Community.new
      community.did = params[:did]
      community.depositor = 'The Previous Depositor'
      community.mods.title = 'A different title' 
      community.project_members = %w(a b c d e)
      community.drupal_access = 'private' 
      community.save!
      community.community = Community.root_community
      community.save!

      UpsertCommunity.upsert params
    end

    after(:all) { ActiveFedora::Base.delete_all } 

    it 'does not build a new community' do 
      expect(Community.count).to eq 2 
    end

    it 'does not update the depositor even when one is provided' do
      expect(community.depositor).to eq 'The Previous Depositor' 
    end

    it_should_behave_like 'a metadata assigning operation' 
    it_should_behave_like 'a thumbnail updating operation'
  end
end
