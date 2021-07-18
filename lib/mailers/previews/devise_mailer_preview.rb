# Preview all emails at http://localhost:3000/rails/mailers/devise_mailer
# :nocov:
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, "faketoken")
  end

  def all_casa_admin_invitation_instructions
    all_casa_admin_invitation_sent_at = AllCasaAdmin.first.invitation_sent_at

    # Temporarily set :invitation_sent_at to guarantee the preview works
    AllCasaAdmin.first.update_attribute(:invitation_sent_at, Date.today)
    preview = Devise::Mailer.invitation_instructions(AllCasaAdmin.first, "faketoken")
    AllCasaAdmin.first.update_attribute(:invitation_sent_at, all_casa_admin_invitation_sent_at)

    preview
  end
end
# :nocov:
