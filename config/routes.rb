TapasRails::Application.routes.draw do

  # At some point we'll want all this, but I'm going to disable these routes
  # until we're ready to migrate to 100% Hydra-Head usage for tapas.
  root :to => "view_packages#index"
  # blacklight_for :catalog
  # devise_for :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Show resque admin in development environment
  resque_web_constraint = lambda do |request|
    Rails.env == "development"
  end

  # constraints resque_web_constraint do
  mount Resque::Server, at: "/resque"
  # end

  # Communities
  get 'communities/:did' => 'communities#show'
  post "communities/:did" => "communities#upsert"
  # delete "communities/:did" => "communities#destroy"

  # Collections
  get 'collections/:did' => 'collections#show'
  post "collections/:did" => "collections#upsert"
  # delete "collections/:did" => "collections#destroy"

  # CoreFiles
  get 'files/:did/mods' => 'core_files#mods'
  get 'files/:did/tei' => 'core_files#tei'
  get 'files/:did' => 'core_files#show'
  put 'files/:did/reading_interfaces' => 'core_files#rebuild_reading_interfaces'
  post 'files/:did' => 'core_files#upsert'
  # delete "files/:did" => "core_files#destroy"

  get 'files/:did/html/:view_package' => 'core_files#view_package_html'

  resources :downloads, :only => 'show'

  resources :view_packages
  get 'api/view_packages' => 'view_packages#api_index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
