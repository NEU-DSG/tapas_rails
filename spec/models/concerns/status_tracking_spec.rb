require 'spec_helper'

describe StatusTracking do 
  class StatusTrackerTest < ActiveFedora::Base
    include StatusTracking

    has_metadata :name => 'properties', :type => PropertiesDatastream 
  end

  describe 'attributes' do 
    let(:subject) { StatusTrackerTest.new } 

    it { respond_to(:errors_display) } 
    it { respond_to(:errors_system) } 
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
      tracker.set_status_code('COMPLETE')
      expect(tracker.upload_status).to eq 'COMPLETE'
      expect(tracker.upload_status_time).not_to be_blank
    end
  end

  describe '#stuck_in_progress?' do 
    let(:tracker) { StatusTrackerTest.new } 

    it 'returns false when no previous status time is set' do 
      expect(tracker.stuck_in_progress?).to be false 
    end

    it 'returns false when the object is not in progress' do 
      # Access properties directly to HACK TIME
      tracker.upload_status = 'COMPLETE' 
      tracker.upload_status_time = 20.minutes.ago.iso8601.to_s 

      expect(tracker.stuck_in_progress?).to be false 
    end

    it 'returns false when the object has not been processing for five mins' do
      tracker.set_status_code('INPROGRESS')
      expect(tracker.stuck_in_progress?).to be false 
    end

    it 'returns true when the object has been processing for 5+ mins' do 
      tracker.upload_status = 'INPROGRESS'
      tracker.upload_status_time = 20.minutes.ago.iso8601.to_s

      expect(tracker.stuck_in_progress?).to be true 
    end
  end
end
