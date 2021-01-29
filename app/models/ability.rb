class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, :all, is_public: true

    return if user.id.nil?

    can :read, Community, community_members: { user_id: user.id }
    can :read, Collection, community: { community_members: { user_id: user.id } }
    can :read, CoreFile, collections: { community: { community_members: { user_id: user.id } } }

    can :create, Community
    can :create, Collection
    can :create, CoreFile

    can :manage, Community, depositor_id: user.id
    can :manage, Community, community_members: { member_type: ["editor", "admin"], user_id: user.id }
    can :manage, Collection, depositor_id: user.id
    can :manage, Collection, community: { community_members: { member_type: ["editor", "admin"], user_id: user.id } }
    can :manage, CoreFile, depositor_id: user.id
    can :manage, CoreFile, collections: { community: { community_members: { member_type: ["editor", "admin"], user_id: user.id } } }

    return unless user.admin?

    can :manage, :all
  end
end
