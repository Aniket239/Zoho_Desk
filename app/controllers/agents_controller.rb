class AgentsController < ApplicationController
    def allAgents
        client_id = '1000.RMODJ3TXVWLVGROZQR2CYKWAQQL4RK'
        client_secret = '7241a1ead9a8513ebea78500298e54fb2db44cee9d'
        refresh_token = cookies[:refresh_token]
        agents_url = "https://desk.zoho.in/api/v1/agents"
        access_token = cookies[:access_token]
        response=HTTParty.get(agents_url,headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}"})
        agents=response.parsed_response
        p "========================= agents ========================"
        p agents
        redirect_to tickets_index_path
    end
end
