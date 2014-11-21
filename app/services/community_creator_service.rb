class CommunityCreatorService 
  include Concerns::TapasObjectCreator

  def create_record
    begin
      community = Community.new
      community.mods.title      = params[:title]
      community.nid             = params[:nid]
      community.project_members = params[:members]
      community.depositor       = "000000000"
          
      # Turns out the drupal site has no notion of nested projects (communities).
      # So Communities can always just belong to the root tapas community
      community.save
      community.community_id = Rails.configuration.tap_root
      community.save
      return community.reload
    rescue => e
      community.delete if community && community.persisted?
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e
    end
  end
end
