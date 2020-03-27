class User < ActiveRecord::Base 
  # Connects this user object to hydra behavior
  include Hydra::User

  delegate :can?, :cannot, to: :ability

  def user_key 
    return self.id.to_s
  end

  def ability
    @ability ||= Ability.new(self) 
  end

  def self.find_by_user_key(id) 
    User.find_by_id(id) 
  end
end