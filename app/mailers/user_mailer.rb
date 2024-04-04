class UserMailer < ApplicationMailer
    def testEmail(content_mail, subject)
      @content = content_mail
      mail(to: "system4@thejaingroup.com", subject:subject, content:'text/html')
    end
  end
  