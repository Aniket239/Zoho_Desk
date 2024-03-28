class TicketsController < ApplicationController
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
  def index
    zoho_desk_service = ZohoDeskApiService.new(cookies[:access_token])
    response = zoho_desk_service.list_tickets
    if response.code == 200
      tickets_data = response.parsed_response
      if tickets_data["data"].present?
        sorted_tickets = tickets_data["data"].sort_by { |ticket| -ticket["ticketNumber"].to_i }
        tickets_data["data"] = sorted_tickets
      end
      @tickets = tickets_data 
    else
      refresh_access_token
      redirect_to tickets_index_path
    end
  end
  def threads
    ticket_id = params[:id]
    cookies[:ticket_id] = ticket_id
    access_token = cookies[:access_token]
    ticket_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
    threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads",headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
    @ticket = ticket_response.parsed_response
    @threads = threads_response.parsed_response
    if @ticket["erroCode"]=="INVALID_OAUTH" || @threads["errorCode"] == "INVALID_OAUTH"
      refresh_access_token
      p refresh_access_token
    end
    p @ticket
    p @threads
  end

  def reply
    ticket_id = cookies[:ticket_id]
    access_token = cookies[:access_token]
    api_url = "https://desk.zoho.in/api/v1/tickets/#{ticket_id}/sendReply"
    reply_data = {
      channel: "EMAIL",
      fromEmailAddress: params[:from],
      to: params[:to],
      cc: params[:cc],
      content: params[:body],
      contentType: 'plainText' # Assuming the content type is HTML; adjust as needed
    }
    response = HTTParty.post(api_url,
                             headers: {
                               'Authorization' => "Zoho-oauthtoken #{access_token}",
                               'Content-Type' => 'application/json'
                             },
                             body: reply_data.to_json)

    if response.code == 200
      p "success"
      redirect_to action: :threads, id: ticket_id
    else
      flash[:alert] = "Failed to send reply"
      p "error"
      p response.code
    end
  end
end
