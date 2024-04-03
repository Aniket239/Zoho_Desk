class UserMailer < ApplicationMailer
    def testEmail(original_email, subject)
      @contents = original_email
      mail(to: "system4@thejaingroup.com", subject:subject, content:'html')
    end
  end
  