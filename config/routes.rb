Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  get '/trends/:season/:battletag/win-loss-chart' => 'trends#win_loss_chart', as: :win_loss_chart
  get '/trends/:season/:battletag/win-loss-chart/per-map' => 'trends#per_map_win_loss_chart', as: :per_map_win_loss_chart
  get '/trends/:season/:battletag/streaks-chart' => 'trends#streaks_chart', as: :streaks_chart
  get '/trends/:season/:battletag/day-chart' => 'trends#day_chart', as: :day_chart
  get '/trends/:season/:battletag/time-chart' => 'trends#time_chart', as: :time_chart
  get '/trends/:season/:battletag/thrower-leaver-chart' => 'trends#thrower_leaver_chart', as: :thrower_leaver_chart
  get '/trends/:season/:battletag/heroes-chart' => 'trends#heroes_chart', as: :heroes_chart

  get '/matches/confirm-wipe/:battletag' => 'matches#wipe_season_select', as: :wipe_season_select, season: /\d+/
  get '/season/:season/:battletag' => 'matches#index', as: :matches, season: /\d+/
  post '/season/:season/:battletag' => 'matches#create', season: /\d+/
  post '/season/:season/:battletag/export' => 'matches#export', as: :export_matches, season: /\d+/
  delete '/season/:season/:battletag' => 'matches#wipe', season: /\d+/
  get '/season/:season/:battletag/confirm-wipe' => 'matches#confirm_wipe', as: :confirm_season_wipe, season: /\d+/
  get '/matches/:id' => 'matches#edit', as: :match
  put '/matches/:id' => 'matches#update'

  get '/settings' => 'users#settings', as: :settings

  get '/accounts' => 'oauth_accounts#index', as: :accounts

  get '/import/:season/:battletag' => 'import#index', as: :import, season: /\d+/
  post '/import/:season/:battletag' => 'import#create', season: /\d+/

  root to: 'login#index'
end
