class UserMailer < ApplicationMailer
  default from: "zohodesk.thejaingroup@gmail.com"
  layout 'mailer'
    def zohoMail(content_mail, subject,recipient_email,agent_name,note,assigneer_email,cc)
      @content = content_mail
      p "================================================ agent_name ========================================= "
      @agent_name = agent_name
      p @agent_name
      p "================================================ note ========================================= "
      @note = note
      p @note
      if cc=="true"
        cc_mail=  "rishi@thejaingroup.com"
      else 
        cc_mail=  nil
      end
      p cc_mail
      mail(to: recipient_email, subject: subject, cc: [cc_mail,assigneer_email], bcc: "system4@thejaingroup.com")
    end
  end

