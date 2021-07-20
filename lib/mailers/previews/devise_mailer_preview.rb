# Preview all emails at http://localhost:3000/rails/mailers/devise_mailer
# :nocov:
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, "faketoken")
  end

  def invitation_instructions_as_all_casa_admin
    all_casa_admin_invitation_sent_at = AllCasaAdmin.first.invitation_sent_at

    # Temporarily set :invitation_sent_at to guarantee the preview works
    AllCasaAdmin.first.update_attribute(:invitation_sent_at, Date.today)
    preview = Devise::Mailer.invitation_instructions(AllCasaAdmin.first, "faketoken")
    AllCasaAdmin.first.update_attribute(:invitation_sent_at, all_casa_admin_invitation_sent_at)

    preview
  end

  def invitation_instructions_as_casa_admin
    casa_admin_invitation_sent_at = CasaAdmin.first.invitation_sent_at

    # Temporarily set :invitation_sent_at to guarantee the preview works
    CasaAdmin.first.update_attribute(:invitation_sent_at, Date.today)
    preview = Devise::Mailer.invitation_instructions(CasaAdmin.first, "faketoken")
    CasaAdmin.first.update_attribute(:invitation_sent_at, casa_admin_invitation_sent_at)

    preview
  end

  def invitation_instructions_as_supervisor
    supervisor_invitation_sent_at = Supervisor.first.invitation_sent_at

    # Temporarily set :invitation_sent_at to guarantee the preview works
    Supervisor.first.update_attribute(:invitation_sent_at, Date.today)
    preview = Devise::Mailer.invitation_instructions(Supervisor.first, "faketoken")
    Supervisor.first.update_attribute(:invitation_sent_at, supervisor_invitation_sent_at)

    preview
  end
end
# :nocov:
