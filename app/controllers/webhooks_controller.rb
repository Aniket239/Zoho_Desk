class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def receive
      request_data = params
        if request_data.dig('_json', 0, 'eventType') == 'Ticket_Update'
        p "==================== webhook data ================="
        p ticket_update_event = request_data['_json'][0]
        p "==================== webhook data ================="
        process_ticket_update(ticket_update_event)
      else
        p "Received a non-ticket update event"
      end
      head :ok
    end
  
    private
  
    def process_ticket_update(event)
      p "Processing Ticket Update Event"
      payload = event['payload'] || {}
      p "Ticket ID: #{payload['id']}"
      p "Ticket Status: #{payload['status']}"
      p "Ticket assigned: #{payload['customFields']['Assignee']}"
    end
  end
  