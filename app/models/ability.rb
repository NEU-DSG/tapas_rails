class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    can :read, :all, is_public: true

    return if user.id.nil?

    can :create, Community
    can :read, Community, community_members: { user_id: user.id }
    can :update, Community, community_members: { member_type: ["editor", "admin"], user_id: user.id }
    can :destroy, Community, depositor_id: user.id

    can :create, Collection
    can :read, Collection, community: { community_members: { user_id: user.id } }
    can :update, Collection, community: { community_members: { member_type: ["editor", "admin"], user_id: user.id } }
    can :destroy, Collection, depositor_id: user.id

    can :create, CoreFile
    can :read, CoreFile, collections: { community: { community_members: { user_id: user.id } } }
    can :update, CoreFile, collections: { community: { community_members: { member_type: ["editor", "admin"], user_id: user.id } } }
    can :destroy, CoreFile, depositor_id: user.id

    return unless user.admin?

    can :manage, :all
  end
end
