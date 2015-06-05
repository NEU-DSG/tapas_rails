require 'spec_helper'

describe HTMLFile do 

  describe "HTML Type" do 
    let(:html_file) { HTMLFile.new } 

    it "raises an error when set to an unexpected value" do 
      e = Exceptions::InvalidHTMLTypeError
      expect { html_file.html_type = "new format" }.to raise_error e 
    end

    it "can be set to an expected value" do 
      html_file.html_type = "teibp" 
      expect(html_file.html_type).to eq "teibp" 
    end
  end
end
