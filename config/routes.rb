Rails.application.routes.draw do
  root 'tickets#login'
  post 'tickets/login'
  get 'tickets/index'
  post 'tickets/index'
  get '/auth', to: 'auth#authorize'
  get '/auth/callback', to: 'auth#callback'
end
