require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '1m' do
    allAgents
  end

  def allAgents
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
    p access_token_response
    if access_token_response.code == 200
        p access_token = access_token_response.parsed_response['access_token']
        agents_response = HTTParty.get("https://desk.zoho.in/api/v1/agents", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
        p agents = agents_response.parsed_response
        agent_id=[]
        agents["data"].each do |agent|
            agent_id<<agent["id"]
        end    
        p "================================"
        p agent_id
        p "================================"
        tickets=[[]]
        agent_id.each do |id|
            tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
            p "============================================== agent #{id} ============================================"
            p tickets_response
            p "============================================== agent #{id} ============================================"
        end    
    else
        p "error while getting access token"
    end
end