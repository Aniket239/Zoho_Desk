class UserMailer < ApplicationMailer
    def testEmail(original_email, subject)
      @contents = original_email.body.decoded
      mail(to: "system4@thejaingroup.com", subject:subject,body:@contents, content:)
    end
  end
  