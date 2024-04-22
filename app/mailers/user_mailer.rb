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
      mail(to:"system4@thejaingroup.com", subject: "Weekly Report") do |format|
        format.html { render layout: 'mailer' }
      end
      p "Mail sent successfully"
    end
    # , cc: [cc_mail,assigneer_email], bcc: "system4@thejaingroup.com"
    def daily_report(tickets)
      @tickets = tickets
      mail(to:"system4@thejaingroup.com", subject: "Daily Report") do |format|
        format.html { render layout: 'mailer' }
      end
      p "Mail sent successfully"
    end  

# ["customercare1@thejaingroup.com","customercare2@thejaingroup.com","customercare3@thejaingroup.com"],bcc:
# ["customercare1@thejaingroup.com","customercare2@thejaingroup.com","customercare3@thejaingroup.com"],bcc:
end