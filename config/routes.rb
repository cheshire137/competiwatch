Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    delete 'sign_out', to: 'users/sessions#destroy', as: :sign_out
  end

  get '/trends/:season/:battletag' => 'trends#index', as: :trends

  get '/seasons/choose-season-to-wipe' => 'seasons#choose_season_to_wipe', as: :choose_season_to_wipe, season: /\d+/
  get '/season/:season/:battletag/confirm-wipe' => 'seasons#confirm_wipe', as: :confirm_season_wipe, season: /\d+/
  delete '/season/:season/:battletag' => 'seasons#wipe', season: /\d+/

  get '/season/:season/:battletag' => 'matches#index', as: :matches, season: /\d+/
  post '/season/:season/:battletag' => 'matches#create', season: /\d+/
  post '/season/:season/:battletag/export' => 'matches#export', as: :export_matches, season: /\d+/
  get '/matches/:season/:battletag/:id' => 'matches#edit', as: :match
  put '/matches/:id' => 'matches#update', as: :update_match

  get '/shared-seasons' => 'season_shares#index', as: :season_shares
  post '/season/:season/:battletag/share' => 'season_shares#create', as: :season_share, season: /\d+/
  delete '/season/:season/:battletag/share' => 'season_shares#destroy', season: /\d+/

  get '/settings' => 'users#settings', as: :settings

  get '/accounts' => 'oauth_accounts#index', as: :accounts
  delete '/accounts/:battletag' => 'oauth_accounts#destroy', as: :account

  get '/import/:season/:battletag' => 'import#index', as: :import, season: /\d+/
  post '/import/:season/:battletag' => 'import#create', season: /\d+/

  get '/stats/all-seasons/:battletag' => 'stats#all_seasons', as: :all_seasons_stats
  get '/stats/all-accounts/:season' => 'stats#all_accounts', as: :all_accounts_stats
  get '/stats' => 'stats#index', as: :stats

  root to: 'login#index'
end
