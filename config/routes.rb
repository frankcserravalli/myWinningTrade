MyWinningTrade::Application.routes.draw do

  match '/auth/:provider/callback', to: 'sessions#create'

  get '/dashboard', to: 'stock#dashboard'
  get '/user/trading_analysis', to: 'stock#trading_analysis'

  get '/login', to: 'sessions#new'
  get '/logout', to: 'sessions#destroy'

  get '/terms', to: 'terms#show', as: :terms
  post '/terms/accept', to: 'terms#accept', as: :accept_terms

  get 'buys/callback_linkedin', to: 'buys#callback_linkedin'
  get 'buys/callback_facebook', to: 'buys#callback_facebook'

  get 'sells/callback_linkedin', to: 'sells#callback_linkedin'
  get 'sells/callback_facebook', to: 'sells#callback_facebook'

  #get '/users/profile', to: 'users#profile', as: 'profile'
  #get '/users/edit', to: 'users#edit'
  #put '/users/update', to: 'users#update'

  get '/trading_analysis_pdf', to: 'users#trading_analysis_pdf'

  get '/subscriptions', to: 'subscriptions#show'
  post '/subscriptions/create', to: 'subscriptions#create'
  match '/subscriptions/destroy', to: 'subscriptions#destroy'
  match '/subscriptions/update', to: 'subscriptions#update'

  resource :teacher_sessions, only: [:create, :destroy]
  get 'teacher/sign_in' => 'teacher_sessions#new'

  resource :groups

  get 'group', to: 'groups#index'

  get '/joestest', to: 'users#test'



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
      post 'users/authenticate' => 'users#authenticate'
      post 'users/create' => 'users#create'
      delete 'users/destroy' => 'users#destroy'
      match '/auth/:provider/callback', to: 'users#authenticate'


      resources :buys, only: :create
      resources :sells, only: :create
      resources :stocks do
        collection do
          post 'search'
          post 'details'
        end
      end
      resources :users do
        collection do
          post 'pending_date_time_transactions'
          post 'pending_stop_loss_transactions'
          post 'portfolio'
          post 'stock_info'
          post 'stock_order_history'

        end
      end
      resource :short_sell_borrows, only: :create
      resource :short_sell_covers, only: :create
      resource :date_time_transactions, only: [:create, :destroy]
      resource :stop_loss_transactions, only: [:create, :destroy]
    end
  end

end
