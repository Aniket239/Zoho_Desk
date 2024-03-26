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
  def update
    p "==================== ticket data ==================="
    @ticket_data = params[:format]
    p @ticket_data
    p "==================== ticket data ==================="
  end
end
