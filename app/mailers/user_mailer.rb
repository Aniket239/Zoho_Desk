class UserMailer < ApplicationMailer
    default from: 'aniketbiswas2392001@gmail.com'
  
    def testEmail
      p "working"
      mail(to: 'system3.thejaingroup@gmail.com', subject: 'Test email')
      p "===================="
    end
  end
  