class UserMailer < ApplicationMailer
  def password_changed_reminder(user)
    @user = user
    @casa_organization = user.casa_org

    mail(to: @user.email, subject: 'CASA Password Changed')
  end
end
