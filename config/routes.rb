Rails.application.routes.draw do
  root :to => "projects#browse"

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

  get 'users/:id' => 'users#profile'
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

  # Projects, formerly 'Communities'
  resources :projects

  # Collections
  resources :collections
  # TODO: add more complex routing to reflect ordered hierarchy, human-readable names


  # Collections
  resources :collections

  # CoreFiles
  resources :core_files

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

  # Browse pages
  get 'browse' => 'projects#browse'
  get 'browse/projects' => 'projects#browse'

  match '/:id' => 'pages#show', via: 'get' #must go at end since it matches on everything
end
