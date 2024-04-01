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
      refresh_token='1000.2b9b9cbdcdadc05749f6d17f19c18ede.7f0255d317ca218bf5c1c56e8d4cdbad'
      p "Processing Ticket Update Event"
      payload = event['payload'] || {}
      ticket_number = payload['ticketNumber']
      ticket_id = payload['id']
      ticket_status = payload['status']
      assigned_to = payload.dig('customFields', 'Assignee')
      assigned_from_pallavita = payload.dig('customFields','Pallavita Assigns To')
  
      p "Ticket Number: #{ticket_number}"
      p "Ticket ID: #{ticket_id}"
      p "Ticket Status: #{ticket_status}"
      if assigned_to!= nil
        p "Assigned To: #{assigned_to}"
      elsif assigned_from_pallavita!= nil
        p "Assigned To: #{assigned_to}"
      end  
      WebhookService.process_ticket(ticket_id,refresh_token)
    end
  end
  