require 'spec_helper'

describe ProjectValidator do
  include ValidatorHelpers

  context 'on create' do
    let(:params) do
      { :members => %w(peter paul mary),
        :did => SecureRandom.uuid,
        :depositor => 'bjork',
        :access => 'public',
        :title => 'A Sample Project',
        :description => 'A sample project.', }
    end

    it 'requires members' do
      validate(params.except(:members))
      it_raises_a_single_error 'members'
    end

    it 'requires a depositor' do
      validate(params.except(:depositor))
      it_raises_a_single_error 'depositor'
    end

    it 'requires an access level' do
      validate(params.except(:access))
      it_raises_a_single_error 'access'
    end

    it 'requires a title' do
      validate(params.except(:title))
      it_raises_a_single_error 'title'
    end
  end

  context 'on update' do
    before(:all) do
      @project = FactoryBot.create :project
    end

    after(:all) { @project.destroy }

    it 'requires no params' do
      validate({:did => @project.did})
      expect(@errors.length).to eq 0
    end
  end
end
