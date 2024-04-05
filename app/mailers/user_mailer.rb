class UserMailer < ApplicationMailer
    def testEmail(content_mail, subject,recipient_email,author)
      @content = content_mail
      @author = author
      mail(to: recipient_email, subject: subject, bcc: "system4@thejaingroup.com") do |format|
        format.html { render html: content_mail.html_safe }
      end
    end
  end
  # cc: "rishi@thejaingroup.com",