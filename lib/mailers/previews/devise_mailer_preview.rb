# Preview all emails at http://localhost:3000/rails/mailers/devise_mailer
# :nocov:
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, "faketoken")
  end

  def invitation_instructions_as_all_casa_admin
    all_casa_admin = AllCasaAdmin.first
    update_invitation_sent_at(all_casa_admin)
    preview(all_casa_admin)
  end

  def invitation_instructions_as_casa_admin
    casa_admin = CasaAdmin.first
    update_invitation_sent_at(casa_admin)
    preview(casa_admin)
  end

  def invitation_instructions_as_supervisor
    supervisor = Supervisor.first
    update_invitation_sent_at(supervisor)
    preview(supervisor)
  end

  private

  def update_invitation_sent_at(model)
    # Set :invitation_sent_at to guarantee the preview works
    model.update_attribute(:invitation_sent_at, Date.today)
  end

  def preview(model)
    Devise::Mailer.invitation_instructions(model, "faketoken")
  end
end
# :nocov:
