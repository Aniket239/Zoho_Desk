class UserMailer < ApplicationMailer
    default from: 'aniketbiswas2392001@gmail.com'
  
    def testEmail(filter_contents,subject)
        @filter_contents = filter_contents
      p "working"
      mail(to: 'system4@thejaingroup.com', subject: "new testing mail chain")
      p "===================="
    end
  end
  