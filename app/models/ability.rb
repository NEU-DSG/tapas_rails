class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, :all

    if user.admin?
      can :manage, :all
    else
      can :manage, Community, depositor_id: user.id
      can :manage, Community, community_members: { member_type: ["editor", "admin"], user_id: user.id }
    end
  end
end
