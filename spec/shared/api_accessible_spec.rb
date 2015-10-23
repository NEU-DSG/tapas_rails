require 'spec_helper'

shared_examples_for "an API enabled controller" do    
  let(:user) { FactoryGirl.create(:user) } 

  describe 'GET #show' do 
    let(:resource) do 
      model = described_class.to_s.sub('Controller', '').singularize.underscore
      resource = FactoryGirl.create :"#{model}"
      resource.mark_upload_complete!
      resource
    end

    before(:each) { ActiveFedora::Base.destroy_all }

    it '404s for bad requests' do 
      get :show, { :did => 'not-a-real-did' } 
      expect(response.status).to eq 404
    end

    it '200s and returns the object as json for valid requests' do 
      get :show, { :did => resource.did }
      expect(response.status).to eq 200 

      full_response = JSON.parse(response.body)
      puts full_response
      object = full_response['message'].with_indifferent_access

      expect(object).to eq resource.as_json.with_indifferent_access
    end
  end

  describe "authentication" do 
    it "raises a 403 for requests with no authorization header" do
      set_auth_token(nil)
      post :upsert, :did => 'whatever'
      expect(response.status).to eq 403
    end

    it "raises a 403 for requests with an invalid token" do 
      set_auth_token('bupkes')
      post :upsert, :did => 'whatever'
      expect(response.status).to eq 403
    end
  end
end
