class CasaAdminMailerPreview < ActionMailer::Preview
  def account_setup
    CasaAdminMailer.account_setup(CasaAdmin.last)
  end
end
