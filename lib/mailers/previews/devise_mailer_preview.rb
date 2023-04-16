# Preview all emails at http://localhost:3000/rails/mailers/devise_mailer
# :nocov:
require_relative "../debug_preview_mailer"
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = params.has_key?(:id) ? User.find_by(id: params[:id]) : User.last
    if user.nil?
      DebugPreviewMailer.invalid_user(user, "user")
    else
      Devise::Mailer.reset_password_instructions(user, "faketoken")
    end
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

  def invitation_instructions_as_volunteer
    volunteer = Volunteer.first
    update_invitation_sent_at(volunteer)
    preview(volunteer)
  end

  private

  # Unused email types

  def update_invitation_sent_at(model)
    # Set :invitation_sent_at to guarantee the preview works
    model.update_attribute(:invitation_sent_at, Date.today)
  end

  def preview(model)
    Devise::Mailer.invitation_instructions(model, "faketoken")
  end

  def email_changed
    user = params.has_key?(:id) ? User.find_by(id: params[:id]) : User.last
    Devise::Mailer.email_changed(user)
  end

  def password_change
    user = params.has_key?(:id) ? User.find_by(id: params[:id]) : User.last
    Devise::Mailer.password_change(user)
  end
end
# :nocov:
