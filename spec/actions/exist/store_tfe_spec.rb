# require 'spec_helper'

# describe Exist::StoreTfe do
#   include FileHelpers
#   include FixtureBuilders

#   before(:all) do
#     unless ENV['TRAVIS']
#       @core_file, @collections, @community = FixtureBuilders.create_all
#       @collections.each do |col|
#         col.community = @community
#         col.save!
#       end
#       @core_file.collections = @collections
#       @core_file.save!

#       @core_file_unindexed = FactoryBot.create :core_file
#       @core_file_unindexed.collections = @collections
#       @core_file_unindexed.save!

#       Exist::StoreTei.execute(fixture_file('tei.xml'), @core_file)
#     end
#   end

#   after(:all) { ActiveFedora::Base.delete_all }

#   it 'raises an error when a did that is not in Exist yet is used' do
#     skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
#     e = RestClient::InternalServerError
#     expect { Exist::StoreTfe.execute(@core_file_unindexed) }.to raise_error e
#   end

#   it 'returns a 201 when TFE is correctly added to an existing TEI document' do
#     skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
#     response = Exist::StoreTfe.execute(@core_file)
#     expect(response.code).to eq 201
#   end
# end
