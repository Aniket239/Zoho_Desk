class UserMailer < ApplicationMailer
    def testEmail(content_mail, subject,email,assigned_by)
      @content = content_mail
      @assigned_by = assigned_by
      mail(to: email, subject:subject, content:'text/html')
    end
  end
  