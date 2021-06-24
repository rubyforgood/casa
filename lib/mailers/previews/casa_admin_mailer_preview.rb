class CasaAdminMailerPreview < ActionMailer::Preview
  def account_setup
    CasaAdminMailer.account_setup(CasaAdmin.last)
  end

  def deactivation
    CasaAdminMailer.deactivation(CasaAdmin.last)
  end
end
