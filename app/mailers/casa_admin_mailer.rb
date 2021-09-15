class CasaAdminMailer < UserMailer
  def deactivation(user)
    @user = user
    @casa_organization = CasaOrg.find(@user.casa_org_id)
    mail(to: @user.email, subject: "Your account has been deactivated")
  end

  def account_setup(user)
    @user = user
    @casa_organization = CasaOrg.find(@user.casa_org_id)
    @token = @user.generate_password_reset_token
    mail(to: @user.email, subject: "Create a password & set up your account")
  end
end
