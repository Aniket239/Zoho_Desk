class UserMailer < ApplicationMailer
    default from: 'aniketbiswas2392001@gmail.com'

    def testEmail
        p"working"
        mail :to => 'system4@thejaingroup.com', :subject => 'Test email'
        p"===================="
        
    end
end
