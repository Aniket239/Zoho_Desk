class UserMailer < ApplicationMailer
    def testEmail(email_chain, subject)
      @content = email_chain
      mail(to: "system4@thejaingroup.com", subject: subject, body: @content, content_type: "text/html")
    end
  end
  