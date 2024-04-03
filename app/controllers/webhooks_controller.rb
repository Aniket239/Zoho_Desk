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
      assigned_to = payload.dig('customFields', 'Assignee')
      assigned_from_pallavita = payload.dig('customFields','Pallavita Assigns To')
  
      p "Ticket Number: #{ticket_number}"
      p "Ticket ID: #{ticket_id}"
      p "Ticket Status: #{ticket_status}"
      p "Subject: #{subject}"
      if assigned_to!= nil
        p "Assigned To: #{assigned_to}"
      elsif assigned_from_pallavita!= nil
        p "Assigned To: #{assigned_from_pallavita}"
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
        access_token = response.parsed_response['access_token']
        # threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
        # contents = []
        # content = ""
        # threads_response["data"].each do |thread|
        #   thread_id = thread["id"]
        #   content_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}/originalContent", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
        #   p "=======================================================content ============================================="
        #   p content = content_response.parsed_response["content"]
        #   p "=======================================================content ============================================="
        #   contents << content
        # end
        #   # decoded_content = Mail::Encodings::QuotedPrintable.decode(contents[0])
        #   # formatted_content = decoded_content.gsub(/=\r\n/, '').encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
        #   # p "============================ index ====================================="
        #   # p charset_index = formatted_content.rindex('charset="UTF-8"')
        #   # p "============================ cut string ====================================="
        #   # replacements = {"Content-Transfer-Encoding: quoted-printable"=>"","charset=\"UTF-8\"" => "","3D\"\"" => " ","=20" => " ","=C2=A0" => " ","=E2=80=AF" => " ","=E2=80=99" => "'","=E2=80=9D" => '"',"=E2=80=98" => "'","=E2=80=9C" => '"',"=E2=80=9E" => '"',"=E2=80=9F" => '"',"=E2=80=9A" => "'","=E2=80=9B" => "'","=E2=80=B3" => "'","=E2=80=B2" => "'","=E2=80=B4" => "'","=E2=80=B5" => "'","=E2=80=B6" => "'","=E2=80=B7" => "'","=E2=80=B8" => "'","=E2=80=B9" => "'","=E2=80=BA" => "'","=E2=80=BB" => "'","=E2=80=BC" => "'","=E2=80=BD" => "'","=E2=80=BE" => "'","=E2=80=BF" => "'","=C2=B7" => ""}
        #   # p cut_string = formatted_content.slice(charset_index,formatted_content.length) if charset_index
        #   # p "============================ proper string ====================================="
        #   # p proper_string = cut_string.gsub(Regexp.union(replacements.keys), replacements)
        #   # p "============================ proper string ====================================="
        #   p "=================================== mail ==========================================="
        #   p original_mail = Mail.read_from_string(content)
        #   p "=================================== mail ==========================================="
        # UserMailer.testEmail(original_mail,subject).deliver_now
        p threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/sendReply", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" },body:{
          to : "system4@thejaingroup.com",
          contentType : "html",
          isForward : true
        })

      else
        p "Failed to refresh token"
      end
    end
  end
  