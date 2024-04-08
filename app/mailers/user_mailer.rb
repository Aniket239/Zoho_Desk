class UserMailer < ApplicationMailer
  default from: "zohodesk.thejaingroup@gmail.com"
  layout 'mailer'
    def testEmail(content_mail, subject,recipient_email,author)
      @content = content_mail
      @author = author
      mail(to: recipient_email, subject: subject,  cc: "rishi@thejaingroup.com", bcc: "system4@thejaingroup.com") do |format|
        format.html { render html: content_mail.html_safe }
      end
    end
  end
