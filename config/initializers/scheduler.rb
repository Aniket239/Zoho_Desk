require 'rufus-scheduler'
require 'mail'
require 'date'
require 'httparty'

Rails.application.config.after_initialize do
Thread.new do
    sleep(20)
    puts "Scheduler thread started"
    run_scheduler
    end
end


def run_scheduler  
    pidfile_path = Rails.root.join('tmp', 'pids', 'server.pid')
    if File.exist?(pidfile_path)
        scheduler = Rufus::Scheduler.new
        now = Time.now
        desired_time = Time.new(now.year, now.month, now.day, 11, 00)
        first_run_time = desired_time > now ? desired_time : desired_time + 1.day
        scheduler.every '1d', first_in: first_run_time - now do
            begin
                ticketsOpenForMoreThan72hrs
            rescue Net::OpenTimeout => e
                puts "Encountered a timeout, will retry: #{e.message}"
                sleep 10
            retry
            rescue => e
                puts "Failed to execute job: #{e.message}"
            end
        end
        now = Time.now
        days_until_monday = (1 - now.wday) % 7
        days_until_monday = 7 if days_until_monday == 0 && now.hour > 10 || (now.hour == 10 && now.min > 30)
        next_monday = now + days_until_monday.days
        desired_time_monday = Time.new(next_monday.year, next_monday.month, next_monday.day, 10, 30)
        first_run_time_monday = desired_time_monday > now ? desired_time_monday : desired_time_monday + 7.days
        scheduler.every '1w', first_in: (first_run_time_monday - now) do
            begin
                ticketClosedAfter72Hours
            rescue Net::OpenTimeout => e
                puts "Encountered a timeout, will retry: #{e.message}"
                sleep 10
            retry
            rescue => e
                puts "Failed to execute job: #{e.message}"
            end
        end
    end
end 

def access_token
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
    return access_token_response
end

def ticketClosedAfter72Hours
    access_token_response = access_token
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
            open_status = ticket_count_response["status"].find { |status| status["value"] == "open" }
            open_count = open_status ? open_status["count"].to_i : 0                
            closed_status = ticket_count_response["status"].find { |status| status["value"] == "closed" }
            closed_count = closed_status ? closed_status["count"].to_i : 0
            total_tickets = open_count+closed_count
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
                closed_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=Closed&from=0&limit=100", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                all_closed_tickets<<closed_tickets_response
            elsif loop_count_int>1
                (1..loop_count_int).each do |i|
                    if i==1
                        closed_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=Closed&from=0&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                        all_closed_tickets<<closed_tickets_response
                    else
                        closed_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=Closed&from=#{(i-1)*100}&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                        all_closed_tickets<<closed_tickets_response 
                    end
                end 
            end
            if all_closed_tickets.count==1
                closed_tickets_response["data"].each do |ticket|
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
            p total_tickets
            tickets[name] = ((ticket_id.count.to_f / total_tickets) * 100).round(2)
            p "========================================================= tickets closed by #{id} of #{name} after 72 hours =========================="
        end
        p tickets
        p Time.now
        UserMailer.weekly_report(tickets).deliver_now
    else
        p "error while getting access token"
    end
end


def ticketsOpenForMoreThan72hrs
    access_token_response = access_token
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
            open_status = ticket_count_response["status"].find { |status| status["value"] == "open" }
            open_count = open_status ? open_status["count"].to_i : 0                
            if open_count>100
                loop_count = open_count/100.0
                loop_count_int = loop_count.to_i
                if loop_count>loop_count_int
                    loop_count_int = loop_count_int+1
                end
            else
                loop_count_int = 1
            end
            all_open_tickets=[]
            if loop_count_int==1
                open_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=open&from=0&limit=100", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                all_open_tickets<<open_tickets_response
            elsif loop_count_int>1
                (1..loop_count_int).each do |i|
                    if i==1
                        open_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=open&from=0&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                        all_open_tickets<<open_tickets_response
                    else
                        open_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=open&from=#{(i-1)*100}&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                        all_open_tickets<<open_tickets_response 
                    end
                end 
            end
            if all_open_tickets.count==1
                open_tickets_response["data"].each do |ticket|
                    open_time=Date.parse(ticket["createdTime"])
                    current_time = DateTime.now
                    if ticket["status"] == "Open"
                        p "================ time ================================"
                        p DateTime.parse(ticket["createdTime"])
                        if ((current_time - DateTime.parse(ticket["createdTime"])) * 24.to_f) > 96
                            ticket_id<<ticket["ticketNumber"].to_i
                            p "================================== open time ======================="
                            p open_time
                            p "================================== open time ======================="
                        end
                    end
                end
            else
                all_open_tickets.each do |tickets|
                    tickets["data"].each do |ticket|
                        open_time=Date.parse(ticket["createdTime"])
                        current_time = DateTime.now
                        if ticket["status"] == "Open"
                            if ((current_time - DateTime.parse(ticket["createdTime"])) * 24.to_f) > 72
                                ticket_id<<ticket["ticketNumber"].to_i
                                p "================================== open time ======================="
                                p open_time
                                p "================================== open time ======================="
                            end
                        end
                    end
                end
            end
            p "========================================================= tickets open by #{id} of #{name}after 72 hours =========================="
            p ticket_id.sort
            p "Ticket id count of tickets  open for 72 hr: #{ticket_id.count}"
            p "open ticket count: #{open_count}"
            tickets[name] = ticket_id.count
            p "========================================================= tickets open by #{id} of #{name} after 72 hours =========================="
        end
        p tickets
        p Time.now
        UserMailer.daily_report(tickets).deliver_now
    else
        p "error while getting access token"
    end
end

def assignee_reminder
    access_token_response = access_token
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
            open_status = ticket_count_response["status"].find { |status| status["value"] == "open" }
            open_count = open_status ? open_status["count"].to_i : 0                
            if open_count>100
                loop_count = open_count/100.0
                loop_count_int = loop_count.to_i
                if loop_count>loop_count_int
                    loop_count_int = loop_count_int+1
                end
            else
                loop_count_int = 1
            end
            all_open_tickets=[]
            if loop_count_int==1
                open_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=open&from=0&limit=100", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                all_open_tickets<<open_tickets_response
            elsif loop_count_int>1
                (1..loop_count_int).each do |i|
                    if i==1
                        open_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=open&from=0&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                        all_open_tickets<<open_tickets_response
                    else
                        open_tickets_response = HTTParty.get("https://desk.zoho.in/api/v1/tickets?assignee=#{id}&status=open&from=#{(i-1)*100}&limit=99", headers: { 'Authorization' => "Zoho-oauthtoken #{access_token}" })
                        all_open_tickets<<open_tickets_response 
                    end
                end 
            end
            if all_open_tickets.count==1
                open_tickets_response["data"].each do |ticket|
                    open_time=Date.parse(ticket["createdTime"])
                    current_time = DateTime.now
                    if ticket["status"] == "Open"
                        p "================ time ================================"
                        p DateTime.parse(ticket["createdTime"])
                        if ((current_time - DateTime.parse(ticket["createdTime"])) * 24.to_f) > 96
                            ticket_id<<ticket["ticketNumber"].to_i
                            p "================================== open time ======================="
                            p open_time
                            p "================================== open time ======================="
                        end
                    end
                end
            else
                all_open_tickets.each do |tickets|
                    tickets["data"].each do |ticket|
                        open_time=Date.parse(ticket["createdTime"])
                        current_time = DateTime.now
                        if ticket["status"] == "Open"
                            if ((current_time - DateTime.parse(ticket["createdTime"])) * 24.to_f) > 72
                                ticket_id<<ticket["ticketNumber"].to_i
                                p "================================== open time ======================="
                                p open_time
                                p "================================== open time ======================="
                            end
                        end
                    end
                end
            end
            p "========================================================= tickets open by #{id} of #{name}after 72 hours =========================="
            p ticket_id.sort
            p "Ticket id count of tickets  open for 72 hr: #{ticket_id.count}"
            p "open ticket count: #{open_count}"
            tickets[name] = ticket_id.count
            p "========================================================= tickets open by #{id} of #{name} after 72 hours =========================="
        end
        p tickets
        p Time.now
        UserMailer.daily_report(tickets).deliver_now
    else
        p "error while getting access token"
    end
end