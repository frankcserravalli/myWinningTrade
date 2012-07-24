MyWinningTrade::Application.routes.draw do

  root to: 'sessions#dashboard'

  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  resources :stock, only: :show, constraints: { id: /\w{1,5}/ } do
    member do
      get :details
      get :price_history
    end
  end
end
