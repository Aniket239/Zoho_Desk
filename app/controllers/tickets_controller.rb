class TicketsController < ApplicationController
    def index
      # Assuming ZohoDeskService is the service object handling the API calls
      zoho_desk_service = ZohoDeskApiService.new(session[:_zoho_desk_session])
      p "zoho desk service"
      p zoho_desk_service
      response = zoho_desk_service.list_tickets
      p "response tickets"
      p response
      if response.code == 200
        @tickets = response.parsed_response
      else
        # Handle error, log it or show a message
        flash[:error] = "Error fetching tickets: #{response.message}"
        redirect_to root_path
      end
    end
end
