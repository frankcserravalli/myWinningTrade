MyWinningTrade::Application.routes.draw do

  root to: 'sessions#dashboard'

  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

end
