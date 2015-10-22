require 'spec_helper'

describe StatusTracking do 
  class StatusTrackerTest < ActiveFedora::Base
    include StatusTracking

    has_metadata :name => 'properties', :type => PropertiesDatastream 
  end

  describe 'attributes' do 
    let(:subject) { StatusTrackerTest.new } 

    it { respond_to(:validation_errors) } 
    it { respond_to(:stacktrace) } 
    it { respond_to(:upload_status) } 
    it { respond_to(:upload_status_time) } 
  end

  describe '#set_status_code' do 
    let(:tracker) { StatusTrackerTest.new }

    it 'raises an error when passed an invalid status code' do 
      expect { tracker.set_status_code('1') }.to raise_error 
    end

    it 'assigns both code and datetime on success' do 
      tracker.set_status_code('SUCCESS')
      expect(tracker.upload_status).to eq 'SUCCESS'
      expect(tracker.upload_status_time).not_to be_blank
    end
  end
end
