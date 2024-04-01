class UserMailer < ApplicationMailer
    default from: 'aniketbiswas2392001@gmail.com'
  
    def testEmail(subject,ticket,threads)
        @ticket = ticket
        @threads = threads
      p "working"
      mail(to: 'system4@thejaingroup.com', subject: subject)
      p "===================="
    end
  end
  