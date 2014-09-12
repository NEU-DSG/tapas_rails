require 'spec_helper'

describe TEIValidator do 

  def validate_file(file)
    return TEIValidator.validate_file(file)
  end

  it "returns errors on malformed xml" do 
    errors = validate_file("<a>xml")
    expect(errors.length).to eq 1 
    expect(errors.first).to eq "Premature end of data in tag a line 1"
  end

  it "returns errors on files that aren't TEI data" do 
    namespace_error = "outermost element is not a TEI element " +
                      "(i.e., is not in the TEI namespace)"

    no_header_error = "no 'teiHeader' element found as child of outermost " +
                      "element"

    root_node_error =  "outermost element is not 'TEI' or 'teiCorpus'"

    errors = validate_file("<a>xml</a>")
    expect(errors.length).to eq 3
    expect(errors).to include namespace_error
    expect(errors).to include no_header_error
    expect(errors).to include root_node_error 
  end

  it "returns no errors on files that are valid TEI data" do 
    tei    = File.read Rails.root.join "spec", "fixtures", "files", "tei.xml"
    errors = validate_file tei 

    expect(errors.length).to eq 0 
  end
end