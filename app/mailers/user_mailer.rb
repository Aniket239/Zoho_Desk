class UserMailer < ApplicationMailer
  default from: "zohodesk.thejaingroup@gmail.com"
  layout 'mailer'
    def zohoMail(content_mail, subject,recipient_email,agent_name,note,assigneer_email,cc)
      @content = content_mail
      @agent_name = agent_name
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
      mail = mail(to: "system4@thejaingroup.com", subject: "Weekly Report")
      p "Attempting to send email to system4@thejaingroup.com"
      mail.deliver
      p "Email sent successfully"
    rescue StandardError => e
      p "Failed to send email: #{e.message}"
    end
    # , cc: [cc_mail,assigneer_email], bcc: "system4@thejaingroup.com"
  end

