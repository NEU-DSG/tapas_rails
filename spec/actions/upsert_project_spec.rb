require 'spec_helper'

describe Upsertproject do
  include FileHelpers

  def params
    { :did => '123',
      :depositor => '011',
      :description => 'This project is a test',
      :title => 'A sample project',
      :access => 'public',
      :members => ['011', '023', '034'],
      :thumbnail => tmp_fixture_file('image_copy.jpg'),
    }
  end

  subject(:project) { Project.find_by_did(params[:did]) }

  RSpec.shared_examples 'a metadata assigning operation' do
    its('title')     { should eq params[:title] }
    its('mods.title')     { should eq [params[:title]] }
    its(:drupal_access)   { should eq params[:access] }
    its(:mass_permissions) { should eq 'public' }
    its('mods.abstract')  { should eq [params[:description]] }
    its(:project_members) { should match_array params[:members] }
  end

  RSpec.shared_examples 'a thumbnail updating operation' do
    its('thumbnail_1.content') { should_not be nil }
    its('thumbnail_1.label') { should eq 'image_copy.jpg' }

    it 'deletes the file' do
      expect(File.exists?(tmp_fixture_file('image_copy.jpg'))).to be false
    end
  end

  context 'Create' do
    context 'with a thumbnail specified' do
      before(:all)  do
        clean_projects
        copy_fixture('image.jpg', 'image_copy.jpg')
        Upsertproject.execute params
      end

      after(:all) do
        clean_projects
      end

      it 'builds the requested project' do
        expect(project.class).to eq Project
      end

      it 'assigns the project as a child of the root project' do
        expect(project.project.pid).to eq Project.root_project.pid
      end

      it_should_behave_like 'a metadata assigning operation'
      it_should_behave_like 'a thumbnail updating operation'
    end

    context 'with no thumbnail specified' do
      before(:all) do
        Upsertproject.execute(params.except(:thumbnail))
      end

      after(:all) do
        clean_projects
      end

      it 'assigns no content to the thumbnail' do
        expect(project.thumbnail_1.content).to eq(nil)
      end

      it_should_behave_like 'a metadata assigning operation'
    end
  end

  context 'Update' do
    before(:all) do
      copy_fixture('image.jpg', 'image_copy.jpg')
      project = Project.new
      project.did = params[:did]
      project.depositor = 'The Previous Depositor'
      project.title = 'A different title'
      project.project_members = %w(a b c d e)
      project.drupal_access = 'private'
      project.save!
      project.project = Project.root_project
      project.save!
      @count_before = Project.count

      UpsertProject.execute params
    end

    after(:all) do
      clean_projects
    end

    it 'does not build a new project' do
      expect(Project.count).to eq @count_before
    end

    it 'does not update the depositor even when one is provided' do
      expect(project.depositor).to eq 'The Previous Depositor'
    end

    it_should_behave_like 'a metadata assigning operation'
    it_should_behave_like 'a thumbnail updating operation'
  end

  def clean_projects
    if Project.find_by_did("123")
      Project.find_by_did("123").destroy
    end
    if Project.count > 1
      Project.delete_all
    end
  end
end
