class TicketsController < ApplicationController
    def index
      zoho_desk_service = ZohoDeskApiService.new(cookies[:access_token])
      response = zoho_desk_service.list_tickets
      p "response tickets"
      p response
      if response.code == 200
        @tickets = response.parsed_response
        p "tickets"
        p @tickets
      else
      redirect_to root_path
      end
    end
end
