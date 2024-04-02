class UserMailer < ApplicationMailer
    default from: 'aniketbiswas2392001@gmail.com'
  
    def testEmail(contents,subject)
        @contents = contents
      p "working"
      mail(to: 'system4@thejaingroup.com', subject: subject)
      p "===================="
    end
  end
  