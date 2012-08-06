MyWinningTrade::Application.routes.draw do
  root to: redirect('/dashboard')
  get '/dashboard', to: 'stock#dashboard'

  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  resources :stock, only: :show, constraints: { id: /[a-zA-Z0-9\.\-]{1,20}/ } do
    member do
      get :price_history
    end
    collection do
      get :details
      get :search
    end

    resource :buy, only: :create
    resource :sell, only: :create
  end
end
