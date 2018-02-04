Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions'
  }

  get '/matches/:battletag' => 'matches#index', as: :matches
  post '/matches/:battletag' => 'matches#create'

  root to: 'login#index'
end
