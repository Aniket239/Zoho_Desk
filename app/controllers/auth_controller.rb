class AuthController < ApplicationController
  def authorize
    client_id = '1000.AX7K22BZK6OS35PYCBPO990IEX8ZPC'
    redirect_uri = 'http://localhost:3000/auth/callback'
    # Define all the scopes based on your needs
    scopes = [
        'Desk.tickets.ALL',
        'Desk.tickets.READ',
        'Desk.tickets.WRITE',
        'Desk.tickets.UPDATE',
        'Desk.tickets.CREATE',
        'Desk.tickets.DELETE',
        'Desk.contacts.READ',
        'Desk.contacts.WRITE',
        'Desk.contacts.UPDATE',
        'Desk.contacts.CREATE',
        'Desk.tasks.ALL',
        'Desk.tasks.WRITE',
        'Desk.tasks.READ',
        'Desk.tasks.CREATE',
        'Desk.tasks.UPDATE',
        'Desk.tasks.DELETE',
        'Desk.basic.READ',
        'Desk.basic.CREATE',
        'Desk.settings.ALL',
        'Desk.settings.WRITE',
        'Desk.settings.READ',
        'Desk.settings.CREATE',
        'Desk.settings.UPDATE',
        'Desk.settings.DELETE',
        'Desk.search.READ',
        'Desk.events.ALL',
        'Desk.events.READ',
        'Desk.events.WRITE',
        'Desk.events.CREATE',
        'Desk.events.UPDATE',
        'Desk.events.DELETE',
        'Desk.articles.READ',
        'Desk.articles.CREATE',
        'Desk.articles.UPDATE',
        'Desk.articles.DELETE',
        'Desk.activities.calls.READ',
        'Desk.activities.READ',
        'Desk.activities.calls.UPDATE',
        'Desk.activities.UPDATE',
        'Desk.activities.calls.DELETE',
        'Desk.activities.DELETE',
        'Desk.activities.calls.CREATE', 
        'Desk.activities.CREATE',
        'Desk.InstantMessages.READ',
        'Desk.InstantMessages.CREATE'
    ]
    scope = scopes.join(',')
    response_type = 'code'
    authorization_url = "https://accounts.zoho.com/oauth/v2/auth?response_type=#{response_type}&client_id=#{client_id}&scope=#{scope}&redirect_uri=#{redirect_uri}&access_type=offline&prompt=consent"
    redirect_to authorization_url
  end

  def callback
    authorization_code = params[:code]
    p "authorization code"
    p authorization_code
    client_id = '1000.AX7K22BZK6OS35PYCBPO990IEX8ZPC'
    client_secret = '69f04bf294dee8d3a69c77367163af960c83814985'
    redirect_uri = 'http://localhost:3000/auth/callback'

    token_url = "https://accounts.zoho.in/oauth/v2/token"

    response = HTTParty.post(token_url, body: {
      code: authorization_code,
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      grant_type: 'authorization_code'
    })
    access_token = response.parsed_response['access_token']
    cookies[:access_token] = access_token
    refresh_token = response.parsed_response['refresh_token']
    cookies[:refresh_token] = refresh_token
    redirect_to agents_login_path, notice: 'You have been successfully authenticated!'
  end
end
