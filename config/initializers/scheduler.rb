require 'rufus-scheduler'
require 'mail'
require 'date'
require 'httparty'

scheduler = Rufus::Scheduler.new

    scheduler.every '1m' do
        begin
            ticketClosedAfter72Hours
        rescue Net::OpenTimeout => e
            puts "Encountered a timeout, will retry: #{e.message}"
            sleep 10 # wait 10 seconds before retrying
        retry
        rescue => e
            puts "Failed to execute job: #{e.message}"
        end
    end

    def weekly_report_72hr(tickets)
        UserMailer.weekly_report(tickets).deliver_now
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
            agents = agents_response.parsed_response
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
                closed_status = ticket_count_response["status"].find { |status| status["value"] == "closed" }
                closed_count = closed_status ? closed_status["count"].to_i : 0
                if closed_count>100
                    loop_count = closed_count/100.0
                    loop_count_int = loop_count.to_i
                    if loop_count>loop_count_int
                        loop_count_int = loop_count_int+1
                    end
                else
                    loop_count_int = 1
                end
                all_closed_tickets=[]
                if loop_count_int==1
                    tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=Closed&from=0&limit=100", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                    all_closed_tickets<<tickets_response
                elsif loop_count_int>1
                    (1..loop_count_int).each do |i|
                        if i==1
                            tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=Closed&from=0&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                            all_closed_tickets<<tickets_response
                        else
                            tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=Closed&from=#{(i-1)*100}&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                            all_closed_tickets<<tickets_response 
                        end
                    end 
                end
                if all_closed_tickets.count==1
                    tickets_response["data"].each do |ticket|
                        close_time=Date.parse(ticket["closedTime"])
                        today = Date.today
                        beginning_of_this_week = today.beginning_of_week
                        beginning_of_last_week = (today - 1.week).beginning_of_week
                        if ticket["status"] == "Closed" && close_time >= beginning_of_last_week && close_time < beginning_of_this_week
                            if (((DateTime.parse(ticket["closedTime"]) - DateTime.parse(ticket["createdTime"]))* 24).to_f) > 72
                                ticket_id<<ticket["ticketNumber"].to_i
                                p "================================== close time ======================="
                                p close_time
                                p "================================== close time ======================="
                            end
                        end
                    end
                else
                    all_closed_tickets.each do |tickets|
                        tickets["data"].each do |ticket|
                            close_time=Date.parse(ticket["closedTime"])
                            today = Date.today
                            beginning_of_this_week = today.beginning_of_week
                            beginning_of_last_week = (today - 1.week).beginning_of_week
                            if ticket["status"] == "Closed" && close_time >= beginning_of_last_week && close_time < beginning_of_this_week
                                if (((DateTime.parse(ticket["closedTime"]) - DateTime.parse(ticket["createdTime"]))* 24).to_f) > 72
                                    ticket_id<<ticket["ticketNumber"].to_i
                                    p "================================== close time ======================="
                                    p close_time
                                    p "================================== close time ======================="
                                end
                            end
                        end
                    end
                end
                p "========================================================= tickets closed by #{id} of #{name}after 72 hours =========================="
                p ticket_id.sort
                p "Ticket id count of tickets  closed after 72 hr: #{ticket_id.count}"
                p "closed ticket count: #{closed_count}"
                tickets[name]=ticket_id.count
                p "========================================================= tickets closed by #{id} of #{name} after 72 hours =========================="
            end
            p tickets
            weekly_report_72hr(tickets)
        else
            p "error while getting access token"
        end
    end




