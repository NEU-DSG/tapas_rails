class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, :all

    if user.admin?
      can :manage, :all
    else
      can :manage, Project, depositor_id: user.id
      can :manage, Project, project_members: { role: %w[collaborator owner], id: user.id }
      can :manage, Collection, depositor_id: user.id
      can :manage, Collection, project: { project_members: { role: %w[collaborator owner], id: user.id } }
      can :manage, CoreFile, depositor_id: user.id
      can :manage, CoreFile, collections: { project: { project_members: { role: %w[collaborator owner], id: user.id } } }
    end
  end
end
