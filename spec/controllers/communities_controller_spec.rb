require 'rails_helper'

describe CommunitiesController do
  include ControllerHelpers

  let(:institution) { FactoryBot.create(:institution) }
  let(:user) { FactoryBot.create(:user, institution: institution) }
  let(:editor) { FactoryBot.create(:user, institution: institution) }
  let(:member) { FactoryBot.create(:user, institution: institution) }

  def params
    {
      community: {
        description: 'foo',
        institutions: [institution],
        project_admins: [user],
        project_editors: [editor],
        project_members: [member],
        title: 'community title'
      }
    }
  end

  describe '#index' do
    it 'renders the communities index' do
      communities = FactoryBot.create_list(:community, 3, depositor: user, is_public: true)

      get :index

      expect(assigns(:results)).to eq(communities)
      expect(response).to render_template('shared/index')
    end
  end

  describe '#show' do
    it 'renders the specified community' do
      community = FactoryBot.create(:community)

      get :show, params: { id: community.id }

      expect(assigns(:community)).to eq(community)
      expect(response).to render_template('show')
    end

    it 'does not allow unauthorized access to a private community' do
      community = FactoryBot.create(:community, is_public: false)

      expect { get :show, params: { id: community.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows authorized access to a private community' do
      community = FactoryBot.create(:community, depositor: user, is_public: false)

      login_user(user)

      get :show, params: { id: community.id }

      expect(assigns(:community)).to eq(community)
      expect(response).to render_template('show')
    end
  end

  describe '#new' do
    it 'does not allow non-logged-in users' do
      get :new

      expect(response).to redirect_to('/')
    end

    it 'allows a paid logged-in user' do
      paid_user = FactoryBot.create(:user, paid_at: Time.now)

      login_user(paid_user)

      get :new

      expect(response).to render_template('new')
    end
  end

  describe '#create' do
    it 'does not allow a non-logged-in user' do
      expect { post :create, params: params }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows a logged-in user' do
      paid_user = FactoryBot.create(:user, paid_at: Time.now)

      login_user(paid_user)

      post :create, params: params

      expect(response).to redirect_to("/communities/#{assigns(:community).id}")
    end
  end

  describe '#edit' do
    let(:community) { FactoryBot.create(:community, depositor: user) }

    it 'does not allow a non-logged-in user' do
      expect { get :edit, params: { id: community.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'does not allow a non-member' do
      login_user

      expect { get :edit, params: { id: community.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows a member' do
      login_user(user)

      get :edit, params: { id: community.id }

      expect(assigns(:community)).to eq(community)
      expect(response).to render_template('edit')
    end

    it 'allows an admin' do
      login_admin

      get :edit, params: { id: community.id }

      expect(assigns(:community)).to eq(community)
      expect(response).to render_template('edit')
    end
  end

  describe '#update' do
    let(:community) { FactoryBot.create(:community, depositor: user) }

    it 'does not allow a non-logged-in user' do
      expect { post :update, params: params.merge(id: community.id) }.to raise_error(CanCan::AccessDenied)
    end

    it 'does not allow a non-editor/-admin' do
      login_user

      expect { post :update, params: params.merge(id: community.id) }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows an editor' do
      login_user(user)

      post :update, params: params.merge(id: community.id)

      expect(assigns(:community).title).to eq(params[:community][:title])
      expect(response).to redirect_to("/communities/#{community.id}")
    end

    it 'allows an admin' do
      login_admin

      post :update, params: params.merge(id: community.id)

      expect(assigns(:community).title).to eq(params[:community][:title])
      expect(response).to redirect_to("/communities/#{community.id}")
    end
  end

  describe '#destroy' do
    let(:community) { FactoryBot.create(:community, depositor: user) }

    it 'does not allow a non-logged-in user' do
      expect { delete :destroy, params: { id: community.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'does not allow a non-member' do
      login_user

      expect { delete :destroy, params: { id: community.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows an editor' do
      login_user(user)

      delete :destroy, params: { id: community.id }

      expect(response).to redirect_to('/my_tapas')
    end

    it 'allows an admin' do
      login_admin

      delete :destroy, params: { id: community.id }

      expect(response).to redirect_to('/my_tapas')
    end
  end
end
