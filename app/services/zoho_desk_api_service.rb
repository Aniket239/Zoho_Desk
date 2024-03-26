class ZohoDeskApiService
    include HTTParty
    base_uri 'https://desk.zoho.in/api/v1'

    def initialize(access_token)
      @access_token = access_token
    end

    def headers
      {
        "Authorization" => "Zoho-oauthtoken #{@access_token}",
        "Content-Type" => "application/json"
      }
    end
    def list_tickets
        self.class.get('/tickets', headers: { 'Authorization' => "Zoho-oauthtoken #{@access_token}" })
    end

  end

#   https://accounts.zoho.com/oauth/v2/auth?scope=Desk.tickets.ALL&client_id=1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK&response_type=code&access_type=offline&redirect_uri=http://localhost:3000/auth/callback
