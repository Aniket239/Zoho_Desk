class AuthController < ApplicationController
    def authorize
        client_id = '1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK'
        redirect_uri = 'http://localhost:3000/auth/callback'
        scope = 'Desk.tickets.ALL'  # Define the scope based on your needs
        response_type = 'code'
        authorization_url = "https://accounts.zoho.com/oauth/v2/auth?response_type=#{response_type}&client_id=#{client_id}&scope=#{scope}&redirect_uri=#{redirect_uri}&access_type=offline&prompt=consent"

        redirect_to authorization_url
      end

      def callback
        authorization_code = params[:code]
        p "authorization code"
        p authorization_code
        client_id = '1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK'
        client_secret = '7241a1ead9a8513ebea78500298e54fb2db44cee9d'
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
        cookies.encrypted[:expire_time]=response.parsed_response['expires_in']
        redirect_to tickets_index_path, notice: 'You have been successfully authenticated!'
      end

      def refresh_access_token
        client_id = '1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK'
        client_secret = '7241a1ead9a8513ebea78500298e54fb2db44cee9d'
        refresh_token = cookies[:refresh_token]
        token_url = "https://accounts.zoho.in/oauth/v2/token"

        response = HTTParty.post(token_url, body: {
          refresh_token: refresh_token,
          client_id: client_id,
          client_secret: client_secret,
          grant_type: 'refresh_token'
        })

        if response.code == 200
          new_access_token = response.parsed_response['access_token']
          cookies[:access_token] = new_access_token
          new_refresh_token = response.parsed_response['refresh_token']
          cookies[:refresh_token] = new_refresh_token if new_refresh_token
          p "New access token generated"
          return new_access_token
        else
          p "Failed to refresh token"
        end
      end
end
