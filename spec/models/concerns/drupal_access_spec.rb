# require 'spec_helper'

# class DrupalAccessTester < ActiveFedora::Base
#   include DrupalAccess
#   has_metadata :name => "properties", :type => PropertiesDatastream
# end

# describe "The Drupal Access Module" do
#   let(:tester) { DrupalAccessTester.new }
#   after(:each) { ActiveFedora::Base.delete_all }

#   it "gives access to drupal_access getter/setters" do
#     tester.drupal_access = "public"
#     expect(tester.drupal_access).to eq "public"
#   end
# end
