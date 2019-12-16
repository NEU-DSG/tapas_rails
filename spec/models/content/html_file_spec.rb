require 'spec_helper'

describe HTMLFile do

  describe "HTML Type" do
    let(:html_file) { HTMLFile.new }

    it "raises an error when set to an unexpected value" do
      skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
      FactoryGirl.create :tapas_generic
      FactoryGirl.create :teibp

      e = Exceptions::InvalidHTMLTypeError
      expect { html_file.html_type = "new format" }.to raise_error e
    end

    it "can be set to an expected value" do
      skip("Test passes locally but not on Travis.") if ENV['TRAVIS']
      FactoryGirl.create :tapas_generic
      FactoryGirl.create :teibp

      html_file.html_type = "teibp"
      expect(html_file.html_type).to eq "teibp"
    end
  end

  it_behaves_like 'DownloadPath'
end
