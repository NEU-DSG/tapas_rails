require 'spec_helper'

describe CoreFilesController do
  let (:user) { FactoryGirl.create(:user) }

  it_should_behave_like "an API enabled controller"
end
