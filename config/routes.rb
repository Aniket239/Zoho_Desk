Rails.application.routes.draw do
  get '/auth', to: 'auth#authorize'
  get '/auth/callback', to: 'auth#callback'

  post '/webhook/assignTo', to: 'webhooks#assignTo'
  post '/webhook/status', to: 'webhooks#status'

  root 'tickets#login'
  post 'tickets/login'
  get 'tickets/index'
  post 'tickets/index'
  get 'tickets/threads'
  post 'tickets/threads'
  get 'tickets/edit'
  post 'tickets/edit'
  get 'tickets/reply'
  post 'tickets/reply'
  get 'agents/allAgents'
  post 'agents/allAgents'
  get 'agents/login'
  post 'agents/login'

  get 'tickets/emailTest'
  post 'tickets/emailTest'
  get 'tickets/emailTest', to: 'tickets#emailTest'
  get 'tickets/reports'
  post 'tickets/reports'

end
