class UserMailer < ApplicationMailer
  default from: "zohodesk.thejaingroup@gmail.com"
  layout 'mailer'
    def zohoMail(content_mail, subject,recipient_email,agent_name,note)
      @content = content_mail
      p "================================================ agent_name ========================================= "
      @agent_name = agent_name
      p @agent_name
      p "================================================ note ========================================= "
      @note = note
      p @note
      mail(to: recipient_email, subject: subject, bcc: "system4@thejaingroup.com") 
    end
  end

  # cc: "rishi@thejaingroup.com"
