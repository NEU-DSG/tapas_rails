class CommunityCreator
  include Concerns::TapasObjectCreator

  def create_record
    begin
      community = Community.new
      community.mods.title      = params[:title]
      community.nid             = params[:nid]
      community.project_members = params[:members]
      community.depositor       = params[:depositor]
      community.drupal_access   = params[:access]
          
      # Turns out the drupal site has no notion of nested projects (communities).
      # So Communities can always just belong to the root tapas community
      community.save
      community.community = Community.root_community
      community.save
      return community.reload
    rescue => e
      community.delete if community && community.persisted?
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e
    end
  end
end
