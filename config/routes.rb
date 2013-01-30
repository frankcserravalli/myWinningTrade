MyWinningTrade::Application.routes.draw do
  get '/dashboard', to: 'stock#dashboard'
  get '/user/trading_analysis', to: 'stock#trading_analysis'

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
    resource :short_sell_borrow, only: :create
    resource :short_sell_cover, only: :create
    resource :date_time_transaction, only: [:create, :destroy]
    resource :stop_loss_transaction, only: [:create, :destroy]
  end

  resources :orders, only: [:index]

  root to: redirect('/dashboard')

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :buys, only: :create
      resources :sells, only: :create
      resources :stocks do
        collection do
          get 'search'
          get 'details'
        end
      end
      resources :users do
        collection do
          get 'pending_date_time_transactions'
          get 'pending_stop_loss_transactions'
          get 'portfolio'
          get 'stock_info'
          get 'stock_order_history'
        end
      end
      resource :short_sell_borrows, only: :create
      resource :short_sell_covers, only: :create
      resource :date_time_transactions, only: [:create, :destroy]
      resource :stop_loss_transactions, only: [:create, :destroy]
    end
  end

end
