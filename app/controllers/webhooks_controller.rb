class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def receive
      request_data = params
      if request_data.dig('_json', 0, 'eventType') == 'Ticket_Update'
        ticket_update_event = request_data.dig('_json', 0)
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
      ticket_number = payload['ticketNumber']
      ticket_id = payload['id']
      ticket_status = payload['status']
      assigned_to = payload.dig('customFields', 'Assignee')
      content = payload['firstThread']['content']
  
      p "Ticket Number: #{ticket_number}"
      p "Ticket ID: #{ticket_id}"
      p "content: #{content}"
      p "Ticket Status: #{ticket_status}"
      p "Assigned To: #{assigned_to}"
    end
  end
  