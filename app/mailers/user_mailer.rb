class UserMailer < ApplicationMailer
    def testEmail(decoded_content, subject)
      @contents = decoded_content
      mail(to: "system4@thejaingroup.com", subject: subject, body: @contents, content_type: "text/html")
    end
  end
  