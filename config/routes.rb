TapasRails::Application.routes.draw do

  # At some point we'll want all this, but I'm going to disable these routes
  # until we're ready to migrate to 100% Hydra-Head usage for tapas. 
  # root :to => "catalog#index"
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

  constraints resque_web_constraint do 
    mount Resque::Server, at: "/resque" 
  end

  # Communities
  post "communities/upsert" => "communities#upsert"
  delete "communities/:did" => "communities#destroy"

  # Collections
  post "collections/upsert" => "collections#upsert" 
  delete "collections/:did" => "collections#destroy"

  # CoreFiles
  get 'files/:did/teibp' => 'core_files#teibp'
  get 'files/:did/tapas_generic' => 'core_files#tapas_generic'
  get 'files/:did/tei' => 'core_files#tei'
  post 'files/:did' => 'core_files#upsert'
  post 'files/:did/metadata' => 'core_files#add_metadata'
  delete "files/:did" => "core_files#destroy"

  resources :downloads, :only => 'show'

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
