class TicketsController < ApplicationController
    def refresh_access_token
    client_id = '1000.AX7K22BZK6OS35PYCBPO990IEX8ZPC'
    client_secret = '69f04bf294dee8d3a69c77367163af960c83814985'
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
    agent_id = cookies.encrypted[:agent_id]
    access_token = cookies[:access_token]
    tickets = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{agent_id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
    if tickets.code == 200
      tickets_data = tickets.parsed_response
      if tickets_data["data"].present?
        sorted_tickets = tickets_data["data"].sort_by { |ticket| -ticket["ticketNumber"].to_i }
        tickets_data["data"] = sorted_tickets
      end
      @tickets = tickets_data 
      p @tickets
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
      contentType: 'plainText'
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
      p "error"
      p response.code
    end
  end

  def reports
  
  end   
end
