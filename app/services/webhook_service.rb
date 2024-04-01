class WebhookService
    def self.process_ticket(ticket_id,refresh_token)
        client_id = '1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK'
        client_secret = '7241a1ead9a8513ebea78500298e54fb2db44cee9d'
        token_url = "https://accounts.zoho.in/oauth/v2/token"
    
        response = HTTParty.post(token_url, body: {
          refresh_token: refresh_token,
          client_id: client_id,
          client_secret: client_secret,
          grant_type: 'refresh_token'
        })
    
        if response.code == 200
          access_token = response.parsed_response['access_token']
          ticket_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
          threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads",headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
          ticket = ticket_response.parsed_response
          threads = threads_response.parsed_response
          p "=========================== ticket =================================="
          p ticket
          p "============================ ticket ===================================="
          p "==============================threads=================================="
          p threads
          p "================================ threads ================================="
        else
          p "Failed to refresh token"
        end
    end
  end
  