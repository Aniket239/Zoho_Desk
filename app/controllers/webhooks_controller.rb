class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    require 'mail'

    def assignTo
      request_data = params
      if request_data.dig('_json', 0, 'eventType') == 'Ticket_Update'
        ticket_update_event = request_data.dig('_json', 0)
        refresh_token='1000.4ba1d6b204ab1c7ecc7d90428b9eda3e.5e14e172761ec699949d20447711e9db'
        payload = ticket_update_event['payload'] || {}
        ticket_number = payload['ticketNumber']
        ticket_id = payload['id']
        ticket_status = payload['status']
        subject = payload['subject']
        assign_to = payload.dig('customFields', 'Assign To')
        note = payload.dig('customFields', 'Note To Assignee')
        assigneer_email = payload.dig('assignee', 'email')
        cc=payload.dig('customFields', 'CC Rishi Jain')
        agent_name = "Mail From"+ ' '+ payload.dig('assignee', 'firstName').to_s + ' ' + payload.dig('assignee', 'lastName').to_s
        if assign_to!= nil
          recipient_email = assign_to.slice(assign_to.rindex(" ")+1,assign_to.length)
        end  
        client_id = '1000.AX7K22BZK6OS35PYCBPO990IEX8ZPC'
        client_secret = '69f04bf294dee8d3a69c77367163af960c83814985'
        token_url = "https://accounts.zoho.in/oauth/v2/token"
        response = HTTParty.post(token_url, body: {
          refresh_token: refresh_token,
          client_id: client_id,
          client_secret: client_secret,
          grant_type: 'refresh_token'
        })
  
        if response.code == 200 && recipient_email
          access_token = response.parsed_response['access_token']
          threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
          contents = []
          threads_response["data"].each do |thread|
            thread_id = thread["id"]
            content_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}/originalContent", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
            # customer_email = content_response.parsed_response["contact"]["email"]
            # content = content_response.parsed_response["content"]
            # mail = Mail.read_from_string(content)
            # if mail.multipart?
            #   html_part = mail.html_part
            #   text_part = mail.text_part
            #   content_parsed =  if html_part
            #                       html_part.decoded
            #                     elsif text_part
            #                       text_part.decoded
            #                     else
            #                       mail.parts.first.decoded
            #                     end
            # else
            #   content_parsed = mail.body.decoded
            # end
            contents << content_response
          end
          p "====================== contents =============================="
          p contents
          api_url = "https://desk.zoho.in/api/v1/tickets/#{ticket_id}/sendReply"
          reply_data = {
            channel: "EMAIL",
            fromEmailAddress: assigneer_email,
            to: recipient_email,
            content:contents[0],
            contentType: 'html',
            isForward: 'true',
            isPrivate:'true'
            }
                      # cc: params[:cc],
          p "========================= response ====================================="
          response = HTTParty.post(api_url,
                                   headers: {
                                     'Authorization' => "Zoho-oauthtoken #{access_token}",
                                     'Content-Type' => 'application/json'
                                   },
                                   body: reply_data.to_json)
          p response
          p "========================= response ====================================="
          if response.code == 200
            p "success"
          else
            p "error"
            p response.code
          end
        else
          p "Failed to refresh token"
        end
      else
        p "Received a non-ticket update event"
      end
      head :ok
    end
  end


  # threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
  #         contents = []
  #         threads_response["data"].each do |thread|
  #           thread_id = thread["id"]
  #           content_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}/originalContent", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
  #           # customer_email = content_response.parsed_response["contact"]["email"]
  #           content = content_response.parsed_response["content"]
  #           mail = Mail.read_from_string(content)
  #           if mail.multipart?
  #             html_part = mail.html_part
  #             text_part = mail.text_part
  #             content_parsed =  if html_part
  #                                 html_part.decoded
  #                               elsif text_part
  #                                 text_part.decoded
  #                               else
  #                                 mail.parts.first.decoded
  #                               end
  #           else
  #             content_parsed = mail.body.decoded
  #           end
  #           contents << content_parsed
  #         end
  #           UserMailer.zohoMail(contents[0],subject,recipient_email,agent_name,note,assigneer_email,cc,ticket_id).deliver_now if recipient_email 