require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '1m' do
    ticketClosedAfter72Hours
  end

  def ticketClosedAfter72Hours
    client_id = '1000.AX7K22BZK6OS35PYCBPO990IEX8ZPC'
    client_secret = '69f04bf294dee8d3a69c77367163af960c83814985'
    token_url = "https://accounts.zoho.in/oauth/v2/token"
    refresh_token='1000.4ba1d6b204ab1c7ecc7d90428b9eda3e.5e14e172761ec699949d20447711e9db'
    access_token_response = HTTParty.post(token_url, body: {
      refresh_token: refresh_token,
      client_id: client_id,
      client_secret: client_secret,
      grant_type: 'refresh_token'
    })
    access_token_response
    if access_token_response.code == 200
        access_token = access_token_response.parsed_response['access_token']
        agents_response = HTTParty.get("https://desk.zoho.in/api/v1/agents", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
        p "============================== agents ==========================================="
        p agents = agents_response.parsed_response
        p "============================== agents ==========================================="
        agent_id=[]
        agent_name=[]
        agents["data"].each do |agent|
            agent_id<<agent["id"]
            agent_name<<agent["name"]
        end    
        tickets={}
        agent_id.each do |id|
            ticket_id=[]
            if id == "142173000000064001"
                name= "PALLABITA GHOSH"
            elsif id == "142173000000191144"
                name = "Rimi Kundu"
            else
                name = "Sarnali Haldar"
            end
            ticket_count_response= HTTParty.get("https://desk.zoho.in/api/v1/ticketsCountByFieldValues?field=status&assigneeId=#{id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
            tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=Closed&limit=100", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
            # p "============================= tickets ===================================="
            # p tickets_response
            # p "============================= tickets ===================================="
            closed_status = ticket_count_response["status"].find { |status| status["value"] == "closed" }
            closed_count = closed_status ? closed_status["count"].to_i : 0    
            tickets_response["data"].each do |ticket|
                if ticket["status"] == "Closed"
                    if (((DateTime.parse(ticket["closedTime"]) - DateTime.parse(ticket["createdTime"]))* 24).to_f) > 72
                        ticket_id<<ticket["ticketNumber"]
                    end
                end
            end
            p "========================================================= tickets closed by #{id} of #{name}after 72 hours=========================="
            p ticket_id
            p "Ticket id count #{ticket_id.count}"
            p "closed ticket count: #{closed_count}"
            p "========================================================= tickets closed by #{id} of #{name} after 72 hours=========================="
        end    
    else
        p "error while getting access token"
    end
end

