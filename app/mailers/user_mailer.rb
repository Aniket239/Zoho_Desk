class UserMailer < ApplicationMailer
    default from: 'system.admin@thejaingroup.com'

    def testEmail
        p"working"
        mail :to => 'system4@thejaingroup.com', :subject => 'Test email'
        p"===================="
        
    end
end
