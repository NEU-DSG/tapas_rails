module FactoryHelpers

  # Ensures that factory dids are always unique.  Because these
  # come from Drupal in the wild, which is the mechanism that guarantees
  # they will be unique, we have to do kludgy things to assure that
  # uniqueness when we're creating them on our own
  def unique_did
    did = SecureRandom.uuid
    while Did.exists_by_did? did do
      did = SecureRandom.uuid
    end
    did
  end
end
