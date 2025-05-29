class Ability
  include CanCan::Ability

  def initialize(user)
    # current User role specification, as of 5/16/25
    # Project Owner can:
    # create/delete project
    # create/delete collections and edit collection metadata and settings
    # manage project membership
    # edit or delete anything in the project
    #
    # Project Contributor can:
    # add records to collections
    # upload records and set configurations for their own specific records (e.g. default view)
    # edit records
    # delete records that they’ve uploaded
    #
    # missing from specification:
    # user management; e.g., can a project owner delete the project depositor? does every project require an owner?

    user ||= User.new # guest user (not logged in)
    can :read, :all

    if user.admin?
      can :manage, :all
    else
      # TODO: this has to be re-configured to determine if a project owner exists and for handling requests in both states; depositor can manage anything they create regardless of role. project owner can manage all users associated with a project, along with that project's content. a contributor can edit project content for project, but can't delete what they did not create, or remove users.
      can :manage, Project, depositor_id: user.id
      can :manage, Project, project_members: { role: %w[contributor owner], id: user.id }
      can :manage, Collection, depositor_id: user.id
      can :manage, Collection, project: { project_members: { role: %w[contributor owner], id: user.id } }
      can :manage, CoreFile, depositor_id: user.id
      can :manage, CoreFile, collections: { project: { project_members: { role: %w[contributor owner], id: user.id } } }
    end
  end
end
