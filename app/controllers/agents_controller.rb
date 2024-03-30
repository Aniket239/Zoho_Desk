class AgentsController < ApplicationController
    def allAgents
        client_id = '1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK'
        client_secret = '7241a1ead9a8513ebea78500298e54fb2db44cee9d'
        agents_url = "https://desk.zoho.in/api/v1/agents"
        access_token = cookies[:access_token]
        response = HTTParty.get(agents_url, headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
        p agents = response.parsed_response
        p "========================= agents ========================"
        return agents
    end

    def login
        email = params[:email]
        p email
        agent = allAgents  
        p agent
        current_agent = agent["data"].find { |agent| agent["emailId"] == email }
        if current_agent
            p "======================== agent id ================="
            cookies.encrypted[:agent_id]=current_agent["id"]
            p cookies.encrypted[:agent_id]
            p "======================== agent id ================="
            redirect_to tickets_index_path
        else
            p "Agent not found"
        end
    end
end
