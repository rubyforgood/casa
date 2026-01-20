class UserMailer < ApplicationMailer
  def password_changed_reminder(user)
    @user = user
    @casa_organization = user.try(:casa_org) || nil

    mail(to: @user.email, subject: "CASA Password Changed")
  end

  def email_changed_notification (user)
    @user = user 


    mail(to: @user.email, subject: "Your CASA account's email has been updated to #{@user.email}")
    
    
  end


end
