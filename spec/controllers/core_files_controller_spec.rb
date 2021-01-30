require 'rails_helper'

describe CoreFilesController do
  include ControllerHelpers

  let(:institution) { FactoryBot.create(:institution) }
  let(:user) { FactoryBot.create(:user, institution: institution) }
  let(:contributor) { FactoryBot.create(:user, institution: institution) }

  let(:community) { FactoryBot.create(:community, depositor: user) }
  let(:collection) { FactoryBot.create(:collection, community: community, depositor: user) }

  def params
    {
      core_file: {
        description: "it's a core file",
        featured: false,
        title: 'a title',
        author_ids: [user.id],
        collection_ids: [collection.id],
        contributor_ids: [contributor.id]
      }
    }
  end

  describe '#index' do
    it 'renders the CoreFiles' do
      core_files = FactoryBot.create_list(:core_file, 3, collections: [collection])

      get :index

      expect(assigns(:results)).to eq(core_files)
      expect(response).to render_template('shared/index')
    end
  end

  describe '#new' do
    it 'does not allow non-logged-in users' do
      expect { get :new }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows logged-in users' do
      login_user

      get :new

      expect(response).to render_template('new')
    end
  end

  describe '#create' do
    it 'does not allow non-logged-in users' do
      expect { post :create, params: params }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows logged-in users' do
      login_user

      post :create, params: params

      expect(response).to redirect_to("/core_files/#{assigns(:file).id}")
    end
  end

  describe '#show' do
    let(:file) { FactoryBot.create(:core_file, collections: [collection], depositor: user) }

    it 'renders the requested file' do
      get :show, params: { id: file.id }

      expect(assigns(:core_file)).to eq(file)
      expect(response).to render_template('show')
    end
  end

  describe '#destroy' do
    let(:file) { FactoryBot.create(:core_file, collections: [collection], depositor: user) }

    it 'does not allow non-logged-in users' do
      expect { delete :destroy, params: { id: file.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'does not allow unauthorized users' do
      login_user

      expect { delete :destroy, params: { id: file.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows authorized users' do
      login_user(user)

      delete :destroy, params: { id: file.id }

      expect(response).to redirect_to("/collections/#{file.collections.first.id}")
    end

    it 'allows admins' do
      login_admin

      delete :destroy, params: { id: file.id }

      expect(response).to redirect_to("/collections/#{file.collections.first.id}")
    end
  end

  describe '#edit' do
    let(:file) { FactoryBot.create(:core_file, collections: [collection], depositor: user) }

    it 'does not allow un-logged-in users' do
      expect { get :edit, params: { id: file.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'does not allow unauthorized users' do
      login_user

      expect { get :edit, params: { id: file.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows authorized users' do
      login_user(user)

      get :edit, params: { id: file.id }

      expect(response).to render_template('edit')
    end

    it 'allows admins' do
      login_admin

      get :edit, params: { id: file.id }

      expect(response).to render_template('edit')
    end
  end

  describe '#update' do
    let(:file) { FactoryBot.create(:core_file, collections: [collection], depositor: user) }

    it 'does not allow non-logged-in users' do
      expect { put :update, params: params.merge(id: file.id) }.to raise_error(CanCan::AccessDenied)
    end

    it 'does not allow unauthorized users' do
      login_user

      expect { put :update, params: params.merge(id: file.id) }.to raise_error(CanCan::AccessDenied)
    end

    it 'allows authorized users' do
      login_user(user)

      put :update, params: params.merge(id: file.id)

      expect(response).to redirect_to("/core_files/#{file.id}")
    end

    it 'allows admins' do
      login_admin

      put :update, params: params.merge(id: file.id)

      expect(response).to redirect_to("/core_files/#{file.id}")
    end
  end
end
