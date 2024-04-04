class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    require 'mail'

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
      subject = payload['subject']
      assign_to = payload.dig('customFields', 'Assign To')
      p "Ticket Number: #{ticket_number}"
      p "Ticket ID: #{ticket_id}"
      p "Ticket Status: #{ticket_status}"
      p "Subject: #{subject}"

      if assign_to!= nil
        p "Assigned To: #{assign_to}"
        # assignd_by = "Sent By Rimi"
        p "======================== email ==================================="
        p email = assign_to.slice(assign_to.rindex(" ")+1,assign_to.length)
        p "======================== email ==================================="
      end  
      client_id = '1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK'
      client_secret = '7241a1ead9a8513ebea78500298e54fb2db44cee9d'
      token_url = "https://accounts.zoho.in/oauth/v2/token"
      response = HTTParty.post(token_url, body: {
        refresh_token: refresh_token,
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'refresh_token'
      })

      if response.code == 200
        p "========================= access token ========================================"
        p access_token = response.parsed_response['access_token']
        p "========================= access token ========================================"
        p threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
        p "============================== thread response ===================================="
        contents = []
        threads_response["data"].each do |thread|
          thread_id = thread["id"]
          content_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}/originalContent", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
          content = content_response.parsed_response["content"]
          mail = Mail.read_from_string(content)
          if mail.multipart?
            html_part = mail.html_part
            text_part = mail.text_part
            content_parsed = if html_part
                      html_part.decoded
                    elsif text_part
                      text_part.decoded
                    else
                      mail.parts.first.decoded
                    end
              mail.parts.each do |part|
                if part.mime_type.start_with?('image/') && part.cid.present?
                  filename = part.filename || "image_#{part.cid}.#{part.mime_type.split('/').last}"
                  File.open(Rails.root.join('public', 'uploads', filename), 'wb') do |file|
                  file.write(part.decoded)
                  end
                  if mail.html_part
                  cid_reference = "cid:#{part.cid}"
                  saved_file_path = "/uploads/#{filename}"
                  mail.html_part.body = mail.html_part.body.decoded.gsub(cid_reference, saved_file_path)
                  end
                end
              end
          else
            content_parsed = mail.body.decoded
          end
          contents << content_parsed
        end
        UserMailer.testEmail(contents[0],subject,email).deliver_now
      else
        p "Failed to refresh token"
      end
    end
  end