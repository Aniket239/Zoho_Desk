class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def receive
      # Assuming the payload is already parsed into a hash (if not, you might need to parse it)
      # Use request.body.read if you need to parse raw JSON string
      request_data = params
  
      # Check if the eventType is 'Ticket_Update'
      if request_data.dig('_json', 0, 'eventType') == 'Ticket_Update'
        # Process the Ticket Update event
        p "==================== webhook data ================="
        ticket_update_event = request_data['_json'][0]
        p "==================== webhook data ================="
        process_ticket_update(ticket_update_event)
      else
        puts "Received a non-ticket update event"
      end
  
      head :ok
    end
  
    private
  
    def process_ticket_update(event)
      # Here you can handle the ticket update event
      # For example, logging the ticket ID and status
      puts "Processing Ticket Update Event"
      payload = event['payload'] || {}
      puts "Ticket ID: #{payload['id']}"
      puts "Ticket Status: #{payload['status']}"
      puts "Ticket assigned: #{payload['customFields']['Assignee']}"
      # Add more processing logic as needed
    end
  end
  