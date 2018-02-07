Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  get '/season/:season/:battletag' => 'matches#index', as: :matches, season: /\d+/
  post '/season/:season/:battletag' => 'matches#create', season: /\d+/
  get '/matches/:id' => 'matches#edit', as: :match
  put '/matches/:id' => 'matches#update'

  get '/settings' => 'users#settings', as: :settings
  put '/settings' => 'users#update'

  get '/import/:season/:battletag' => 'import#index', as: :import, season: /\d+/
  post '/import/:season/:battletag' => 'import#create', season: /\d+/

  root to: 'login#index'
end
