require 'rails_helper'

describe CollectionsController do
  include ControllerHelpers

  let(:institution) { FactoryBot.create(:institution) }
  let(:user) { FactoryBot.create(:user, institution: institution) }
  let(:community) { FactoryBot.create(:community, depositor: user) }

  def params
    {
      collection: {
        community_id: community.id,
        description: 'describe me',
        is_public: true,
        title: 'entitled'
      }
    }
  end

  context 'GET' do
    describe '#index' do
      it 'returns collections' do
        collections = FactoryBot.create_list(:collection, 3, community: community, is_public: true)

        get :index

        expect(response).to render_template('shared/index')
        expect(assigns(:results)).to eq(collections)
      end
    end

    describe '#show' do
      it 'returns the specified collection' do
        c = FactoryBot.create(:collection, is_public: true)

        get :show, { params: { id: c.id } }

        expect(assigns(:collection)).to eq(c)
        expect(assigns(:page_title)).to eq(c.title)
      end
    end

    describe '#new' do
      it 'is successful if the user is logged in' do
        login_user

        get :new

        expect(response).to be_successful
      end

      it 'is not successful if the user is not logged in' do
        expect { get :new }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe '#create' do
    it 'is not successful if the user is not logged in' do
      expect { post :create, params: params }.to raise_error(CanCan::AccessDenied)
    end

    it 'is successful if the user is logged in' do
      login_user

      post :create, params: params

      expect(assigns(:collection).community).to eq(community)
      expect(response).to redirect_to("/collections/#{assigns(:collection).id}")
    end
  end

  describe '#destroy' do
    let!(:collection) { FactoryBot.create(:collection, community: community, depositor: user) }

    it 'is not successful if the user is not logged in' do
      expect { delete :destroy, params: { id: collection.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'is not successful if the user is not authorized' do
      login_user

      expect { delete :destroy, params: { id: collection.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'is successful if the user is an admin' do
      login_admin

      delete :destroy, params: { id: collection.id }

      expect(response).to redirect_to("/communities/#{community.id}")
    end

    it 'is successful if the user is authorized' do
      login_user(user)

      delete :destroy, params: { id: collection.id }

      expect(response).to redirect_to("/communities/#{community.id}")
    end
  end

  describe '#edit' do
    let!(:collection) { FactoryBot.create(:collection, community: community, depositor: user) }

    it 'is not successful if the user is not logged in' do
      expect { get :edit, params: { id: collection.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'is not successful if the user is not authorized' do
      login_user

      expect { get :edit, params: { id: collection.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'is successful if the user is an admin' do
      login_admin

      get :edit, params: { id: collection.id }

      expect(response).to be_successful
    end

    it 'is successful if the user is authorized' do
      login_user(user)

      get :edit, params: { id: collection.id }

      expect(response).to be_successful
    end
  end

  describe '#update' do
    let!(:collection) { FactoryBot.create(:collection, community: community, depositor: user) }

    it 'is not successful if the user is not logged in' do
      expect { put :update, params: params.merge(id: collection.id) }.to raise_error(CanCan::AccessDenied)
    end

    it 'is not successful if the user is not authorized' do
      login_user

      expect { put :update, params: params.merge(id: collection.id) }.to raise_error(CanCan::AccessDenied)
    end

    it 'is successful if the user is an admin' do
      login_admin

      put :update, params: params.merge(id: collection.id)

      expect(assigns(:collection).title).to eq(params[:collection][:title])
    end

    it 'is successful if the user is authorized' do
      login_user(user)

      put :update, params: params.merge(id: collection.id)

      expect(assigns(:collection).title).to eq(params[:collection][:title])
    end
  end
end
