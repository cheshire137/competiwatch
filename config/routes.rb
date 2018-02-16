Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    delete 'sign_out', to: 'users/sessions#destroy', as: :sign_out
  end

  get '/trends/:season/:battletag/win-loss-chart' => 'trends#win_loss_chart', as: :win_loss_chart
  get '/trends/:season/:battletag/map-chart' => 'trends#map_chart', as: :map_chart
  get '/trends/:season/:battletag/streaks-chart' => 'trends#streaks_chart', as: :streaks_chart
  get '/trends/:season/:battletag/day-chart' => 'trends#day_chart', as: :day_chart
  get '/trends/:season/:battletag/time-chart' => 'trends#time_chart', as: :time_chart
  get '/trends/:season/:battletag/day-time-chart' => 'trends#day_time_chart', as: :day_time_chart
  get '/trends/:season/:battletag/thrower-leaver-chart' => 'trends#thrower_leaver_chart', as: :thrower_leaver_chart
  get '/trends/:season/:battletag/heroes-chart' => 'trends#heroes_chart', as: :heroes_chart
  get '/trends/:season/:battletag/group-size-chart' => 'trends#group_size_chart', as: :group_size_chart
  get '/trends/:season/:battletag/group-member-chart' => 'trends#group_member_chart', as: :group_member_chart

  get '/seasons/choose-season-to-wipe' => 'seasons#choose_season_to_wipe', as: :choose_season_to_wipe, season: /\d+/
  get '/season/:season/:battletag/confirm-wipe' => 'seasons#confirm_wipe', as: :confirm_season_wipe, season: /\d+/
  delete '/season/:season/:battletag' => 'seasons#wipe', season: /\d+/

  get '/season/:season/:battletag' => 'matches#index', as: :matches, season: /\d+/
  post '/season/:season/:battletag' => 'matches#create', season: /\d+/
  post '/season/:season/:battletag/export' => 'matches#export', as: :export_matches, season: /\d+/
  get '/matches/:season/:battletag/:id' => 'matches#edit', as: :match
  put '/matches/:id' => 'matches#update', as: :update_match

  get '/settings' => 'users#settings', as: :settings

  get '/accounts' => 'oauth_accounts#index', as: :accounts
  delete '/accounts/:battletag' => 'oauth_accounts#destroy', as: :account

  get '/import/:season/:battletag' => 'import#index', as: :import, season: /\d+/
  post '/import/:season/:battletag' => 'import#create', season: /\d+/

  get '/seasons/:battletag' => 'seasons#index', as: :seasons

  root to: 'login#index'
end
