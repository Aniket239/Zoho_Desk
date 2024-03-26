Rails.application.routes.draw do
  get '/auth', to: 'auth#authorize'
  get '/auth/callback', to: 'auth#callback'
  root 'tickets#login'
  post 'tickets/login'
  get 'tickets/index'
  post 'tickets/index'
  get 'tickets/update'
  post 'tickets/update'
  get 'tickets/edit'
  post 'tickets/edit'
end
