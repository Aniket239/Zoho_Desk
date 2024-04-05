class UserMailer < ApplicationMailer
    def testEmail(content_mail, subject,email,author)
      @content = content_mail
      @author = author
      mail(to: email, subject:subject, content:'text/html')
    end
  end
  