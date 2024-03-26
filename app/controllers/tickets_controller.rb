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

end
