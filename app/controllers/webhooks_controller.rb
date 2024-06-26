class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    require 'mail'
    require 'uri'

    @agent_id
    @department_id

    def access_token
      response = HTTParty.post("https://accounts.zoho.in/oauth/v2/token", body: {
        refresh_token: '1000.28e35ea929c9a136b82cf9d48603e17d.b47ffa18bb065b9026c033fadd38e745',
        client_id: '1000.AX7K22BZK6OS35PYCBPO990IEX8ZPC',
        client_secret: '69f04bf294dee8d3a69c77367163af960c83814985',
        grant_type: 'refresh_token'
      })
      if response.code == 200 
        return access_token = response.parsed_response['access_token']
      else
        p "Failed to refresh token"
      end
      
    end

    def assignTo
      request_data = params
      if request_data.dig('_json', 0, 'eventType') == 'Ticket_Update'
        ticket_update_event = request_data.dig('_json', 0)
        payload = ticket_update_event['payload'] || {}
        ticket_number = payload['ticketNumber']
        ticket_id = payload['id']
        ticket_status = payload['status']
        subject = payload['subject']
        agent_id= payload.dig('assignee', 'id')
        from = payload.dig('contact', 'email')
        to = payload.dig('assignee', 'email')
        assign_to = payload.dig('customFields', 'Assign To')
        if assign_to!= nil
          recipient_email = assign_to.slice(assign_to.rindex(" ")+1,assign_to.length)
          recipient_name = assign_to.slice(0,assign_to.rindex(" ")+1)
        end 
        note = payload.dig('customFields', 'Note To Assignee')
        assigneer_email = payload.dig('assignee', 'email')
        cc=payload.dig('customFields', 'CC Rishi Jain')
        if cc=="true"
          cc_email= "rishi@thejaingroup.com"
        else
          cc_email=nil
        end
        agent_name = "Mail From"+ ' '+ payload.dig('assignee', 'firstName').to_s + ' ' + payload.dig('assignee', 'lastName').to_s 
  
        if recipient_email
          p "Recipient email: #{recipient_email}"
          customer_care_emails = ["customercare1@thejaingroup.com", "customercare2@thejaingroup.com", "customercare3@thejaingroup.com"]
          normalized_email = recipient_email.strip.downcase
          unless customer_care_emails.include?(normalized_email)
            threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
            contents = []
            attachment_ids = []
            threads_response["data"].each do |thread|
              thread_id = thread["id"]
              thread_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
              attachment_response = thread_response.parsed_response["attachments"]
              if attachment_response
                attachment_response.each do |attachment|
                  attachment_id = attachment["id"]
                  attachment_ids << attachment_id unless attachment_ids.include?(attachment_id)
                end
              end
              content_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}/originalContent?inline=true", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
              content = content_response.parsed_response["content"]
              mail = Mail.read_from_string(content)
              if mail.multipart?
                html_part = mail.html_part
                text_part = mail.text_part
                content_parsed =  if html_part
                                    html_part.decoded
                                  elsif text_part
                                    text_part.decoded
                                  else
                                    mail.parts.first.decoded
                                  end
              else
                content_parsed = mail.body.decoded
              end
              contents << content_parsed
            end  
            api_url = "https://desk.zoho.in/api/v1/tickets/#{ticket_id}/sendReply"
            button_regex = /<a href="https:\/\/c12b-49-37-8-195.ngrok-free.app\/tickets\/issue[^"]*"[^>]*>\s*Issue Solved\s*<\/a>/
            prompt_regex = /<h3>!!!\s*Kindly click\s*if your issue has been resolved. Otherwise, the issue will remain marked as open in our system.\s*!!!<\/h3>/i
            cleaned_content = contents[0].to_s.gsub(button_regex, '').gsub(prompt_regex, '')
            if note
              content = <<~HTML
              <h3>!!! Kindly click <a href="https://c12b-49-37-8-195.ngrok-free.app/tickets/issue?ticketId=#{ticket_id}&agent_id=#{agent_id}&assignee_name=#{recipient_name}" style="background-color: #4CAF50; border-radius: 5px; color: white; padding: 5px 10px 4px 10px; font-size: 14px; font-family: Helvetica, Arial, sans-serif; text-decoration: none; display: inline-block;">Issue Solved</a> if your issue has been resolved. Otherwise, the issue will remain marked as open in our system. !!!</h3>
              <p>Note: #{note.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')}</p>
              <hr>
              <p style="margin: 0; padding: 0;">============ Forwarded Message ============</p>
              <p style="margin: 0; padding: 0;">From: #{from}</p>
              <p style="margin: 0; padding: 0;">To: #{to}</p>
              <p style="margin: 0; padding: 0;">============ Forwarded Message ============</p>
              <p>#{cleaned_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')}</p>
              HTML
            else
              content = <<~HTML
              <h3>!!! Kindly click <a href="https://c12b-49-37-8-195.ngrok-free.app/tickets/issue?ticketId=#{ticket_id}&agent_id=#{agent_id}&assignee_name=#{recipient_name}" style="background-color: #4CAF50; border-radius: 5px; color: white; padding: 5px 10px 4px 10px; font-size: 14px; font-family: Helvetica, Arial, sans-serif; text-decoration: none; display: inline-block;">Issue Solved</a> if your issue has been resolved. Otherwise, the issue will remain marked as open in our system. !!!</h3>
              <hr>
              <p style="margin: 0; padding: 0;">============ Forwarded Message ============</p>
              <p style="margin: 0; padding: 0;">From: #{from}</p>
              <p style="margin: 0; padding: 0;">To: #{to}</p>
              <p style="margin: 0; padding: 0;">============ Forwarded Message ============</p>
              <p>#{cleaned_content.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')}</p>
              HTML
            end
              reply_data = {
                channel: "EMAIL",
                fromEmailAddress: assigneer_email,
                to: recipient_email,
                cc: cc_email,
                bcc: "system4@thejaingroup.com",
                content: content,
                attachmentIds: attachment_ids,
                contentType: 'html',
                isForward: 'true',
                isPrivate:'true'
              }
            response = HTTParty.post(api_url,headers: {'Authorization' => "Zoho-oauthtoken #{access_token}",'Content-Type' => 'application/json'},body: reply_data.to_json)
            if response.code == 200
              p "success"
              ticket_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
              if ticket_response.code == 200
                ticket_response.parsed_response
              else
                nil
              end
              update_payload = {
                "customFields" => {
                  "Assign To" =>"",
                  "CC Rishi Jain" => "",
                  "Note To Assignee" => "",
                  "Assigned To" => assign_to,
                  "Assigned Date" => Time.now.utc.iso8601,
                  "Note" => note,
                }
              }
              ticket_update_response = HTTParty.put("https://desk.zoho.in/api/v1/tickets/#{ticket_id}",
              headers: {'Authorization' => "Zoho-oauthtoken #{access_token}",'Content-Type' => 'application/json'},
              body: update_payload.to_json)
              if ticket_update_response.code == 200
                puts "Ticket successfully updated."
              else
                puts "Failed to update the ticket. Response code: #{ticket_update_response.code}"
                puts "Response message: #{ticket_update_response.body}"
              end
            else
              p "error"
              p response.code
            end            
          end
        else
          p "Failed to retrieve recipient email"
        end
      else
        p "Received a non-ticket update event"
      end
      head :ok
    end

    def call
      request_data = params
      if request_data.dig('_json', 0, 'eventType') == 'Ticket_Update' && request_data.dig('_json', 0)['payload'].dig('customFields', 'Call Customer') == "true" && request_data.dig('_json', 0)['payload'].dig('customFields', 'CC Rishi Jain') == "false"
        ticket_update_event = request_data.dig('_json', 0)
        p "======================================================================="
        p payload = ticket_update_event['payload'] || {}
        p ticket_number = payload['ticketNumber']
        p ticket_id = payload['id']
        p ticket_status = payload['status']
        p subject = payload['subject']
        p agent_id = payload.dig('assignee', 'id')
        p agent_name = payload.dig('assignee', 'firstName')
        Rails.cache.write(:agent_id, payload.dig('assignee', 'id'))
        Rails.cache.write(:department_id, payload['departmentId'])
        p @department_id = payload['departmentId']
        customer_number = payload.dig('contact', 'phone')
        customer_number = customer_number.gsub(/\s+/, "")  # Remove extra spaces
        puts "Original Phone Number: #{customer_number}"
        if customer_number.match?(/^(\+|)91/)
          puts "Phone number already starts with +91"
        else
          customer_number = "+91#{customer_number}"
          puts "Formatted Phone Number: #{customer_number}"
        end

        p "======================================================================="
        if agent_name == "PALLABITA"
          agent_number = "+918420541541"
        elsif agent_name == "Rimi"
          agent_number = "+917044111333"
        else 
          agent_number = "+919007576657"
        end
        call_response = HTTParty.post("https://kpi.knowlarity.com/Basic/v1/account/call/makecall",
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => 'dff4b494-13d3-4c18-b907-9a830de783ef',
            'x-api-key' => 'LnUmJ62yqp31VLKYR4YlfrYtYOKNIC59viqOXh8g'
          },
          body: {
            "k_number": "+919513436775",
            "agent_number": agent_number,
            "customer_number": customer_number,
            "caller_id": "+918045239626"
          }.to_json
        )
        if call_response.code == 200
          p call_response
          ticket_update_response = HTTParty.put("https://desk.zoho.in/api/v1/tickets/#{ticket_id}",
          headers: {'Authorization' => "Zoho-oauthtoken #{access_token}",'Content-Type' => 'application/json'},
          body: {
            "customFields" => {
              "Call Customer"=>"false"
            }
          }.to_json)
        else
          p "error while calling"
        end
      else
        p "Recieved a non-ticket update event"
      end

      # "============================================= customer contact call button =========================================================="

      if request_data.dig('_json', 0, 'eventType') == 'Contact_Update' && request_data.dig('_json', 0)['payload'].dig('cf', 'cf_call_customer') == "true"
        p "======================================================================="
        ticket_update_event = request_data.dig('_json', 0)
        p payload = ticket_update_event['payload'] || {}
        p contact_id = payload['id']
        p agent_id = payload['ownerId']
        p customer_number = payload['phone']
        customer_number = customer_number.gsub(/\s+/, "")  # Remove extra spaces
        puts "Original Phone Number: #{customer_number}"
        if customer_number.match?(/^(\+|)91/)
          puts "Phone number already starts with +91"
        else
          customer_number = "+91#{customer_number}"
          puts "Formatted Phone Number: #{customer_number}"
        end
        Rails.cache.write(:agent_id, agent_id)
        p "======================================================================="
        if agent_id == "142173000000064001"
          p agent_number = "+918420541541"
          p department_id = "142173000000210031"
            if payload['lastName'] == "Aniket Biswas"
              # p agent_number = "+916295945754"
              p agent_number = "+918597663642"
            end

        elsif agent_id == "142173000000191144"
          p department_id = "142173000000010772"
          p agent_number = "+917044111333"
          if payload['lastName'] == "Aniket Biswas"
            # p agent_number = "+916295945754"
            p agent_number = "+918597663642"
          end
        elsif agent_id == "142173000000233350" 
          p department_id = "142173000000227047"
          p agent_number = "+919007576657"
          if payload['lastName'] == "Aniket Biswas"
            # p agent_number = "+916295945754"
            p agent_number = "+918597663642"
          end
        end
        Rails.cache.write(:department_id, department_id)
        contact_update_response = HTTParty.put("https://desk.zoho.in/api/v1/contacts/#{contact_id}",
        headers: {'Authorization' => "Zoho-oauthtoken #{access_token}",'Content-Type' => 'application/json'},
        body: {
          "cf" => {
            "cf_call_customer"=>"false"
            }
        }.to_json)
        if contact_update_response.code == 200
          p  contact_update_response
        end
        call_response = HTTParty.post("https://kpi.knowlarity.com/Basic/v1/account/call/makecall",
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'Authorization' => 'dff4b494-13d3-4c18-b907-9a830de783ef',
            'x-api-key' => 'LnUmJ62yqp31VLKYR4YlfrYtYOKNIC59viqOXh8g'
          },
          body: {
            "k_number": "+919513436775",
            "agent_number": agent_number,
            "customer_number": customer_number,
            "caller_id": "+918045239626"
          }.to_json
        )
        if call_response.code == 200
          p call_response
        else
          p "error while calling"
        end
      else
        p "Recieved a non-ticket update event"
      end
      head :ok
    end

    def ongoing_call
      request_data = params
      if request_data.dig('_json', 0, 'eventType') == 'Call_Add'
        p "================================ request params data ======================================="
        p payload = request_data.dig('_json', 0)['payload'] || {}
        p "Agent ID #{agent_id = Rails.cache.read(:agent_id)}"
        p "Department ID #{department_id = Rails.cache.read(:department_id)}"
        p "Call ID #{call_id = payload['id']}"
        p "=================================== update owner and department of the call response ===================================="
        max_retries = 3
        retry_count = 0
        retry_delay = 1 # in seconds, adjust as needed
        begin
          p response = HTTParty.put("https://desk.zoho.in/api/v1/calls/#{call_id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" ,'Content-Type' => 'application/json'},
                body: {
                  "ownerId" => agent_id,
                  "departmentId" => department_id
            }.to_json)
        rescue HTTParty::Error => e
          if retry_count < max_retries
            retry_count += 1
            puts "Retry #{retry_count}/#{max_retries}"
            sleep(retry_delay)
            retry
          else
            puts "Max retries reached, aborting"
            raise e
          end
        end
      end     
      # if request_data.dig('_json', 0, 'eventType') == 'Call_Update' && request_data.dig('_json', 0, 'payload')['status'] == "Completed"
      #   p "====================================================== call completed ==================================================="
      #   p payload = request_data.dig('_json', 0)['payload'] || {}
      #   p "Agent ID #{agent_id = Rails.cache.read(:agent_id)}"
      #   p "Department ID #{department_id = Rails.cache.read(:department_id)}"
      #   p "Call ID #{call_id = payload['id']}"
      #   p call_get_response = HTTParty.get("https://desk.zoho.in/api/v1/calls/#{call_id}?include=livecalls", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" ,'Content-Type' => 'application/json'})
      #   if call_get_response.code == 200
      #     p recording_url = call_get_response.parsed_response['livecall']['recordings'][0]['url']
      #     p subject = call_get_response.parsed_response['subject']
      #     p direction = call_get_response.parsed_response['direction']
      #     p contact_id = call_get_response.parsed_response['contactId']
      #     p status = call_get_response.parsed_response['status']
      #     p start_time = call_get_response.parsed_response['startTime']
      #     p livecall_id = call_get_response.parsed_response['livecall']['id']
      #     p duration = payload['duration']
      #     max_retries = 3
      #     retry_count = 0
      #     retry_delay = 1 # in seconds, adjust as needed
      #     begin
      #       p call_get_response = HTTParty.post("https://desk.zoho.in/api/v1/calls", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" ,'Content-Type' => 'application/json'},
      #       body:{
      #       "departmentId" => department_id,
      #       "subject" => subject,
      #       "direction" => direction,
      #       "status" => "Current call",
      #       "ownerId" => agent_id,
      #       "contactId" => contact_id,
      #       "startTime" => start_time
      #       }.to_json)
      #     rescue HTTParty::Error => e
      #       if retry_count < max_retries
      #         retry_count += 1
      #         puts "Retry #{retry_count}/#{max_retries}"
      #         sleep(retry_delay)
      #         retry
      #       else
      #         puts "Max retries reached, aborting"
      #         raise e
      #       end
      #     end
      #   end
      # end
      head :ok
    end
  end