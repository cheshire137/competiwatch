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

  get '/accounts' => 'oauth_accounts#index', as: :accounts
  delete '/accounts/:battletag' => 'oauth_accounts#destroy', as: :account
  put '/accounts/set-default' => 'oauth_accounts#set_default', as: :set_default_account
  get '/profile/:battletag' => 'oauth_accounts#show', as: :profile

  get '/import/:season/:battletag' => 'import#index', as: :import, season: /\d+/
  post '/import/:season/:battletag' => 'import#create', season: /\d+/

  get '/admin' => 'admin#index', as: :admin
  post '/admin/merge-users' => 'admin#merge_users', as: :admin_merge_users
  post '/admin/update-account' => 'admin#update_account', as: :admin_update_account
  put '/admin/season' => 'admin#update_season', as: :admin_update_season
  post '/admin/season' => 'admin#create_season', as: :admin_create_season
  delete '/admin/season' => 'admin#destroy_season', as: :admin_destroy_season

  get '/.well-known/acme-challenge/:id' => 'pages#lets_encrypt'

  root to: 'login#index'
end
