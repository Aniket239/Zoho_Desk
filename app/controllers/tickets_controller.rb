class TicketsController < ApplicationController
  require 'mail'
    def refresh_access_token
    client_id = '1000.AX7K22BZK6OS35PYCBPO990IEX8ZPC'
    client_secret = '69f04bf294dee8d3a69c77367163af960c83814985'
    refresh_token='1000.4ba1d6b204ab1c7ecc7d90428b9eda3e.5e14e172761ec699949d20447711e9db'
    p "refresh token: #{refresh_token}"
    token_url = "https://accounts.zoho.in/oauth/v2/token"

    response = HTTParty.post(token_url, body: {
      refresh_token: refresh_token,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: 'refresh_token'
    })
    if response.code == 200
      new_access_token = response.parsed_response['access_token']
      cookies[:access_token] = new_access_token
      new_refresh_token = response.parsed_response['refresh_token']
      cookies[:refresh_token] = new_refresh_token if new_refresh_token
      p "New access token generated"
      return new_access_token
    else
      p "Failed to refresh token"
    end
  end

  def index
    agent_id = cookies.encrypted[:agent_id]
    access_token = cookies[:access_token]
    p "====================================== tickets ================================="
    p tickets = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{agent_id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
    p "====================================== tickets ================================="
    if tickets.code == 200
      tickets_data = tickets.parsed_response
      if tickets_data["data"].present?
        sorted_tickets = tickets_data["data"].sort_by { |ticket| -ticket["ticketNumber"].to_i }
        tickets_data["data"] = sorted_tickets
      end
      @tickets = tickets_data
      p @tickets 
    else
      refresh_access_token
      redirect_to tickets_index_path
    end
  end
  
  def threads
    ticket_id = params[:ticketId]
    cookies[:ticket_id] = ticket_id
    access_token = refresh_access_token 
    p "========================= ticket threads =================================="
    p threads_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
    p "========================= ticket threads =================================="
    contents = []
    threads_response["data"].each do |thread|
      thread_id = thread["id"]
      content_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets/#{ticket_id}/threads/#{thread_id}/originalContent", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
      # customer_email = content_response.parsed_response["contact"]["email"]
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
    p "============================================ threads ============================================"
    p @threads = contents[0]
    # if threads_response["errorCode"] == "INVALID_OAUTH"
    #   refresh_access_token
    # end
  end

  def reply
    ticket_id = cookies[:ticket_id]
    access_token = cookies[:access_token]
    api_url = "https://desk.zoho.in/api/v1/tickets/#{ticket_id}/sendReply"
    reply_data = {
      channel: "EMAIL",
      fromEmailAddress: params[:from],
      to: params[:to],
      cc: params[:cc],
      content: params[:body],
      contentType: 'plainText'
    }
    response = HTTParty.post(api_url,
                             headers: {
                               'Authorization' => "Zoho-oauthtoken #{access_token}",
                               'Content-Type' => 'application/json'
                             },
                             body: reply_data.to_json)

    if response.code == 200
      p "success"
      redirect_to action: :threads, id: ticket_id
    else
      p "error"
      p response.code
    end
  end
  def issue

  end
  def issue_solved
    
  end
end
