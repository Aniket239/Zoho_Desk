class TicketsController < ApplicationController
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
      p @tickets
    else
      redirect_to root_path
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
      redirect_to root_path
    end
    p "Ticket response:"
    p @ticket
    p "Threads response:"
    p @threads
  end

  def reply
    ticket_id = cookies[:ticket_id]
    p "ticket id"
    p ticket_id
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
    p "reply data"
    p reply_data
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
