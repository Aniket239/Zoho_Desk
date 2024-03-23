class AuthController < ApplicationController
    def authorize
        client_id = ZOHO_DESK_CONFIGURATION[:client_id]
        redirect_uri = ZOHO_DESK_CONFIGURATION[:redirect_uri]
        scope = 'Desk.tickets.ALL'  # Define the scope based on your needs
        response_type = 'code'
    
        authorization_url = "https://accounts.zoho.com/oauth/v2/auth?response_type=#{response_type}&client_id=#{client_id}&scope=#{scope}&redirect_uri=#{redirect_uri}&access_type=offline&prompt=consent"
        
        redirect_to authorization_url
      end
      def callback
        authorization_code = params[:code]
        p "authorization code"
        p authorization_code
        client_id = ZOHO_DESK_CONFIGURATION[:client_id]
        client_secret = ZOHO_DESK_CONFIGURATION[:client_secret]
        redirect_uri = ZOHO_DESK_CONFIGURATION[:redirect_uri]
      
        token_url = "https://accounts.zoho.com/oauth/v2/token"
        
        response = HTTParty.post(token_url, body: {
          code: authorization_code,
          client_id: client_id,
          client_secret: client_secret,
          redirect_uri: redirect_uri,
          grant_type: 'authorization_code'
        })

      
        access_token = response.parsed_response['access_token']
        p "================================================================="
        p access_token
        p "response"
        p response
        p "================================================================"
        # Save the access token securely (e.g., in your database or session)
        p "================================================================"
        session[:access_token] = access_token
        p session[:access_token]
        p "================================================================"
        
        redirect_to tickets_index_path, notice: 'You have been successfully authenticated!'
      end
      
end
