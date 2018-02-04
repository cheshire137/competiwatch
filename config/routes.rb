Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  get '/matches/:battletag' => 'matches#index', as: :matches
  post '/matches/:battletag' => 'matches#create'

  get '/settings' => 'users#settings', as: :settings
  put '/settings' => 'users#update'

  root to: 'login#index'
end
