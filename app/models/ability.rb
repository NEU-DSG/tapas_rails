class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, :all, is_public: true

    if user.admin?
      can :manage, :all
    else
      can :manage, Community, depositor_id: user.id
      can :manage, Community, community_members: { member_type: ["editor", "admin"], user_id: user.id }
      can :read, Community, community_members: { user_id: user.id }
      can :manage, Collection, depositor_id: user.id
      can :manage, Collection, community: { community_members: { member_type: ["editor", "admin"], user_id: user.id } }
      can :read, Collection, community: { community_members: { user_id: user.id } }
      can :manage, CoreFile, depositor_id: user.id
      can :manage, CoreFile, collections: { community: { community_members: { member_type: ["editor", "admin"], user_id: user.id } } }
      can :read, CoreFile, collections: { community: { community_members: { user_id: user.id } } }
    end
  end
end
