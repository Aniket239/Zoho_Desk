class WebhookService
  def self.process_ticket(ticket_id, refresh_token)
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
      threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })

      contents = []  # Initialize an empty array to store content
      threads_response["data"].each do |thread|
        thread_id = thread["id"]
        content_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}/originalContent", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
        
        # Append the content to the array
        contents << content_response.parsed_response["content"]
      end

      p "============================ Content =============================="
      p contents
      # extracted_content_data = contents.map do |content|
      #   date_match = content.match(/Date: (.+?)(\n|\r\n)/)
      #   charset_match = content.match(/charset="UTF-8"\n\n(.*)/m)
      #   date = date_match[1] if date_match
      #   charset = charset_match[1] if charset_match
      
      #   { date: date, charset: charset }
      # end
      # p "================================= extracted content ====================================="
      # p extracted_content_data
    else
      p "Failed to refresh token"
    end
  end
end
