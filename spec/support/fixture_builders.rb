module FixtureBuilders
  # Creates a CoreFile, attached to some number of collections,
  # attached to a Community.  Returns a triplet of the form
  # CoreFile, [Collections], Community
  def self.create_all(collections = 1)
    core = FactoryBot.create :core_file
    collections = FactoryBot.create_list(:collection, collections)
    community = FactoryBot.create :community

    core.collections = collections
    core.save!

    collections.each { |collection| collection.community = community }
    collections.each { |collection| collection.save! }

    return core, collections, community
  end
end
