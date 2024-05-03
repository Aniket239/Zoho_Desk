class UserMailer < ApplicationMailer
  default from: "zohodesk.thejaingroup@gmail.com"
  layout 'mailer'
    def zohoMail(content_mail, subject,recipient_email,agent_name,note,assigneer_email,cc,ticket_id)
      @content = content_mail
      @agent_name = agent_name
      p @ticket_id = ticket_id
      # @customer_email = customer_email
      @note = note
      if cc=="true"
        cc_mail=  "rishi@thejaingroup.com"
      else 
        cc_mail=  nil
      end
      mail(to: recipient_email, subject: subject, cc: [cc_mail,assigneer_email], bcc: "system4@thejaingroup.com")
    end
    
    def weekly_report(tickets)
      @tickets = tickets
      mail(to:["customercare1@thejaingroup.com","customercare2@thejaingroup.com","customercare3@thejaingroup.com"],bcc:"system4@thejaingroup.com", subject: "Weekly Report") do |format|
        format.html { render layout: 'mailer' }
      end
      p "Mail sent successfully"
    end
    # , cc: [cc_mail,assigneer_email], bcc: "system4@thejaingroup.com"
    def daily_report(tickets)
      @tickets = tickets
      mail(to:["customercare1@thejaingroup.com","customercare2@thejaingroup.com","customercare3@thejaingroup.com"],bcc:"system4@thejaingroup.com", subject: "Daily Report") do |format|
        format.html { render layout: 'mailer' }
      end
      p "Mail sent successfully"
    end  

  def assignee_reminder(mail_data)
    if mail_data
        p @data = mail_data
        p @ticket_id= @data["id"]
        p @agent_id = @data["agent_id"]
        p @agent_name = @data["agent_name"]
        p @assignee_name = @data["assignee_name"]
        p @subjects= @data["subject"]
        p @assigned_date= @data["assigned_date"]
        mail(to:"system4@thejaingroup.com", subject: "Daily Reminder")
    end
  end
end

# ["customercare1@thejaingroup.com","customercare2@thejaingroup.com","customercare3@thejaingroup.com"],bcc: