# require 'spec_helper'

# class DidTester < ActiveFedora::Base
#   include Did
#   has_metadata :name => "mods", :type => ModsDatastream
# end

# describe "The Did module" do
#   let(:tester) { DidTester.new }

#   after(:each) do
#     ActiveFedora::Base.delete_all
#   end

#   it "gives access to did setter/getter methods" do
#     expect(tester.respond_to? :did).to be true
#     expect(tester.respond_to? :did=).to be true
#   end

#   it "allows us to look up objects by did" do
#     tester.did = "3014"
#     tester.save!
#     expect(DidTester.find_by_did("3014").id).to eq tester.pid
#   end

#   it "returns nil when an item doesn't exist" do
#     expect(DidTester.find_by_did("2111")).to be nil
#   end

#   it "returns nil when an item of the wrong class is searched for" do
#     c = Collection.new
#     c.depositor = "Johnny"
#     c.title = "Test"
#     c.save!
#     expect(DidTester.find_by_did("#{c.did}")).to be nil
#   end

#   it "allows us to check if a did is already in use" do
#     expect(Did.exists_by_did?("not_used")).to be false

#     begin
#       c = Collection.new
#       c.did = "not_used"
#       c.depositor = "whomever"
#       c.title = "Test"
#       c.save!

#       expect(Did.exists_by_did? "not_used").to be true
#     ensure
#       c.delete if c.persisted?
#     end
#   end

#   it "raises an error if we attempt to reuse a did" do
#     collection = FactoryBot.create :collection
#     core_file = FactoryBot.create :core_file
#     core_file.did = collection.did
#     expect { core_file.save! }.to raise_error Exceptions::DuplicateDidError
#   end

#   it "doesn't raise an error when we 'reuse a did' by updating an object" do
#     collection = FactoryBot.create :collection
#     collection.depositor = 'Changed'
#     expect { collection.save! }.not_to raise_error
#   end
# end
