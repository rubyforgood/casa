class CasaAdminMailer < ApplicationMailer
  def deactivation(user)
    @category = __callee__
    @user = user
    @casa_organization = CasaOrg.find(@user.casa_org_id)
    @subject = "Your account has been deactivated"

    mail(to: @user.email, subject: @subject)
  end

  def account_setup(user)
    @category = __callee__
    @user = user
    @casa_organization = CasaOrg.find(@user.casa_org_id)
    @subject = "Create a password & set up your account"
    @token = @user.generate_password_reset_token
    
    mail(to: @user.email, subject: @subject)
  end
end
