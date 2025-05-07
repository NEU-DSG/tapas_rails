class OgraphyType < ApplicationRecord
  DEFINITIONS = {
    personography: "structured, biographical data on individuals — TEI body is primarily composed of 1 or more <listPerson>s",
    orgography: "structured data about organizations — TEI body is primarily composed of 1 or more <listOrg>s",
    bibliography: "structured data about books and other citable records — TEI body is primarily composed of 1 or more <listBibl>s",
    otherography: "structured data in a format not otherwise described here",
    odd_file: "a description of an XML schema and specification — TEI body is primarily composed of <schemaSpec> (or other documentary
    # elements)",
    placeography: "structured data about locations — TEI body is primarily composed of 1 or more <listPlace>s"
  }.freeze

  def self.list
    DEFINITIONS.keys.map(&:to_s)
  end
end
