Rails.application.routes.draw do
  get '/auth', to: 'auth#authorize'
  get '/auth/callback', to: 'auth#callback'
  root 'tickets#login'
  post 'tickets/login'
  get 'tickets/index'
  post 'tickets/index'
  get 'tickets/threads'
  post 'tickets/threads'
  get 'tickets/edit'
  post 'tickets/edit'
end
