MyWinningTrade::Application.routes.draw do
  get '/mu-5d9c2a33-c3a9f9bc-9a40fca3-2b407512' do
    '42'
  end
  get '/dashboard', to: 'stock#dashboard'

  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  get '/terms', to: 'terms#show', as: :terms
  post '/terms/accept', to: 'terms#accept', as: :accept_terms

  resources :stock, only: :show, constraints: { id: /[a-zA-Z0-9\.\-]{1,20}/ } do
    member do
      get :price_history
    end
    collection do
      get :details
      get :search
      get :portfolio
    end

    resource :buy, only: :create
    resource :sell, only: :create
  end

  resources :orders, only: [:index]

  root to: redirect('/dashboard')
end
