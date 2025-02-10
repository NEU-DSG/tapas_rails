TapasRails::Application.routes.draw do
  
  root :to => "catalog#browse"

  resources :catalog, controller: 'catalog', only: [:index, :show] do
    collection do
      get 'browse'
    end
  end

  devise_for :users, :controllers => {
    :registrations => "users/registrations",
    :sessions => "users/sessions",
    :invitations => 'users/invitations',
    :confirmations => 'users/confirmations'
  }

  get 'my_tapas' => 'users#my_tapas'
  # 2025-02: removed "my_projects", "my_collections", and "my_records"
  get 'admin/users/new' => 'users#admin_new', as: 'admin_new_user'
  get 'admin/users/:id' => 'users#admin_show'
  post 'admin/users' => 'users#admin_create', as: 'admin_create_user'
  get 'users/:id' => 'users#profile'
  get 'mail_users' => 'users#mail_all_users', as: 'mail_users'
  post 'mail_users' => 'users#mail_all_users'

# Show resque admin in development environment
  resque_web_constraint = lambda do |request|
    Rails.env == "development"
  end

  # constraints resque_web_constraint do
  mount Resque::Server.new, at: "/resque"
  # end

  get 'browse' => 'catalog#browse'

  # Projects, formerly 'Communities'
  post "projects/:id" => "projects#upsert" # TODO: upsert -> update
  resources :projects, except: :update
  # TODO: add more complex routing to reflect ordered hierarchy, human-readable names
  #get 'projects/:id' => 'projects#show'
  #get 'projects/:id/edit' => 'projects#edit'
  #get 'projects' => 'projects#index'
  #get '/catalog/:id' => 'projects#show'
  #delete "projects/:id" => "projects#destroy"

  # Collections
  post 'collections/:id' => 'collections#upsert'
  resources :collections, except: :update
  #get 'collections/id' => 'collections#show'
  #get 'collections/id/edit' => 'collections#edit'
  #get 'collections' => 'collections#index'
  #get '/catalog/id' => 'collections#show'
  #delete 'collections/id' => 'collections#destroy'

  # CoreFiles
  resources :core_files
  #get 'core_files/id/edit' => 'core_files#edit'
  #get 'core_files' => 'core_files#index'
  #get 'core_files/new' => 'core_files#new'

  # get 'files/:did/mods' => 'core_files#mods'
  # get 'files/:did/tei' => 'core_files#tei'
  # get 'files/:did' => 'core_files#api_show'
  #get 'core_files/id' => 'core_files#show'
  # put 'core_files/:did/reading_interfaces' => 'core_files#rebuild_reading_interfaces'
  #post 'core_files/id' => 'core_files#update'
  #post 'files/id' => 'core_files#upsert'
  #delete "files/id" => "core_files#destroy"

  # get 'files/:did/html/:view_package' => 'core_files#view_package_html'

  resources :downloads, :only => 'show'

  # namespace :api do
  #   get 'communities/:did' => 'communities#api_show'
  #   get 'collections/:did' => 'collections#api_show'
  #   get 'core_files/:did' => 'core_files#api_show'
  # end

  resources :view_packages
  get 'admin/view_packages/update' => 'view_packages#run_job', as: 'update_view_packages'
  get 'api/view_packages' => 'view_packages#api_index'

  get '/admin' => 'admin#index'
  resources :pages
  resources :news_items, path: "/news"

  resources :menu_links, path: "/menu"
  post 'update_menu_order' => 'menu_links#update_menu_order'

  match '/:id' => 'pages#show', via: 'get' #must go at end since it matches on everything
end
