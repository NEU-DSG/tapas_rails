TapasRails::Application.routes.draw do
  # At some point we'll want all this, but I'm going to disable these routes
  # until we're ready to migrate to 100% Hydra-Head usage for tapas.

  root :to => "view_packages#index"

  # blacklight_for :catalog
  devise_for :users, controllers: { invitations: 'users/invitations' }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Show resque admin in development environment
  resque_web_constraint = lambda do |request|
    Rails.env == "development"
  end

  # constraints resque_web_constraint do
  mount Resque::Server.new, at: "/resque"
  # end
  
  get 'browse' => 'catalog#browse'

  # Communities
  resources :communities
  get 'communities/:did' => 'communities#show'
  get 'communities/:did/edit' => 'communities#edit'
  post "communities/:did" => "communities#upsert"
  get 'communities' => 'communities#index'
  #get '/catalog/:id' => 'communities#show'
  delete "communities/:did" => "communities#destroy"

  # Collections
  resources :collections
  get 'collections/:did' => 'collections#show'
  post "collections/:did" => "collections#upsert"
  get 'collections/:did/edit' => 'collections#edit'
  get 'collections' => 'collections#index'


  # delete "collections/:did" => "collections#destroy"

  # CoreFiles
  resources :core_files
  get 'core_files/:did/edit' => 'core_files#edit'
  get 'core_files' => 'core_files#index'

  get 'files/:did/mods' => 'core_files#mods'
  get 'files/:did/tei' => 'core_files#tei'
  get 'files/:did' => 'core_files#api_show'
  get 'core_files/:did' => 'core_files#show'
  put 'core_files/:did/reading_interfaces' => 'core_files#rebuild_reading_interfaces'
  post 'core_files/:id' => 'core_files#update'
  post 'files/:did' => 'core_files#upsert'
  # delete "files/:did" => "core_files#destroy"

  get 'files/:did/html/:view_package' => 'core_files#view_package_html'

  resources :downloads, :only => 'show'

  namespace :api do
    get 'communities/:did' => 'communities#api_show'
    get 'collections/:did' => 'collections#api_show'
    get 'core_files/:did' => 'core_files#api_show'
  end
  resources :view_packages
  get 'admin/view_packages/update' => 'view_packages#run_job', as: 'update_view_packages'
  get 'api/view_packages' => 'view_packages#api_index'

  get '/admin' => 'admin#index'
  resources :pages
  resources :news_items, path: "/news"
  resources :institutions, path: "/institutions"

  get 'my_tapas' => 'users#my_tapas'
  get 'my_projects' => 'users#my_projects'
  get 'my_collections' => 'users#my_collections'
  get 'my_records' => 'users#my_records'
  get 'admin/users/new' => 'users#admin_new', as: 'admin_new_user'
  get 'admin/users/:id' => 'users#admin_show'
  post 'admin/users' => 'users#admin_create', as: 'admin_create_user'
  get 'users/:id' => 'users#profile'
  get 'mail_users' => 'users#mail_all_users', as: 'mail_users'
  post 'mail_users' => 'users#mail_all_users'
  resources :users, :only => ['index', 'edit', 'create', 'update', 'destroy']
  resources :menu_links, path: "/menu"
  post 'update_menu_order' => 'menu_links#update_menu_order'

  match '/:id' => 'pages#show', via: 'get' #must go at end since it matches on everything
end
