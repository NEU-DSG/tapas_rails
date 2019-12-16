Forem::ApplicationController.class_eval do
  def search_action_url(options = {})
    # Rails 4.2 deprecated url helpers accepting string keys for 'controller' or 'action'
    "/catalog"
  end
end
