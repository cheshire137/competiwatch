Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    delete 'sign_out', to: 'users/sessions#destroy', as: :sign_out
  end

  get '/trends/all-seasons-accounts' => 'trends#all_seasons_accounts', as: :all_seasons_accounts
  get '/trends/all-seasons/:battletag' => 'trends#all_seasons', as: :all_seasons_trends
  get '/trends/all-accounts/:season' => 'trends#all_accounts', as: :all_accounts_trends
  get '/trends/:season/:battletag' => 'trends#index', as: :trends

  get '/seasons/choose-season-to-wipe' => 'seasons#choose_season_to_wipe', as: :choose_season_to_wipe, season: /\d+/
  get '/season/:season/:battletag/confirm-wipe' => 'seasons#confirm_wipe', as: :confirm_season_wipe, season: /\d+/
  delete '/season/:season/:battletag' => 'seasons#wipe', season: /\d+/

  get '/season/:season/:battletag' => 'matches#index', as: :matches, season: /\d+/
  post '/season/:season/:battletag' => 'matches#create', season: /\d+/
  get '/matches/:season/:battletag/:id' => 'matches#edit', as: :match
  put '/matches/:id' => 'matches#update', as: :update_match
  delete '/matches/:id' => 'matches#destroy'

  get '/export' => 'export#index', as: :export
  post '/season/:season/:battletag/export' => 'export#export', as: :export_matches, season: /\d+/

  get '/shared-seasons' => 'season_shares#index', as: :season_shares
  post '/season/:season/:battletag/share' => 'season_shares#create', as: :season_share, season: /\d+/
  delete '/season/:season/:battletag/share' => 'season_shares#destroy', season: /\d+/

  get '/settings' => 'users#settings', as: :settings

  get '/accounts' => 'accounts#index', as: :accounts
  delete '/accounts/:battletag' => 'accounts#destroy', as: :account
  put '/accounts/set-default' => 'accounts#set_default', as: :set_default_account
  get '/profile/:battletag' => 'accounts#show', as: :profile
  put '/profile/:battletag' => 'accounts#update'

  get '/import/:season/:battletag' => 'import#index', as: :import, season: /\d+/
  post '/import/:season/:battletag' => 'import#create', season: /\d+/

  get '/admin' => 'admin/home#index', as: :admin
  get '/admin/users' => 'admin/users#index', as: :admin_users
  post '/admin/users/merge' => 'admin/users#merge', as: :admin_merge_users
  get '/admin/accounts' => 'admin/accounts#index', as: :admin_accounts
  delete '/admin/accounts/prune' => 'admin/accounts#prune', as: :admin_prune_accounts
  get '/admin/account/:id' => 'admin/accounts#show', as: :admin_account
  post '/admin/account' => 'admin/accounts#update', as: :admin_update_account
  put '/admin/account/update-profile' => 'admin/accounts#update_profile', as: :admin_update_account_profile
  get '/admin/seasons' => 'admin/seasons#index', as: :admin_seasons
  put '/admin/season' => 'admin/seasons#update', as: :admin_update_season
  post '/admin/season' => 'admin/seasons#create', as: :admin_create_season
  delete '/admin/season' => 'admin/seasons#destroy', as: :admin_destroy_season

  get '/community' => 'community#index', as: :community

  get '/.well-known/acme-challenge/:id' => 'pages#lets_encrypt'
  get '/about' => 'pages#about', as: :about
  get '/help' => 'pages#help', as: :help

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/401', to: 'errors#unauthorized', via: :all
  match '/403', to: 'errors#forbidden', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all
  match '*path', to: 'errors#not_found', via: :all

  root to: 'login#index'
end
