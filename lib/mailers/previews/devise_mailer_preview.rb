# Preview all emails at http://localhost:3000/rails/mailers/devise_mailer
# :nocov:
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    user = User.find_by(id: params[:id]) || User.last
    Devise::Mailer.reset_password_instructions(user, "faketoken")
  end

  def invitation_instructions_as_all_casa_admin
    all_casa_admin_invitation_sent_at = AllCasaAdmin.first.invitation_sent_at

    # Temporarily set :invitation_sent_at to guarantee the preview works
    AllCasaAdmin.first.update_attribute(:invitation_sent_at, Date.today)
    preview = Devise::Mailer.invitation_instructions(AllCasaAdmin.first, "faketoken")
    AllCasaAdmin.first.update_attribute(:invitation_sent_at, all_casa_admin_invitation_sent_at)

    preview
  end

  def email_changed
    user = User.find_by(id: params[:id]) || User.last
    Devise::Mailer.email_changed(user)
  end

  def password_change
    user = User.find_by(id: params[:id]) || User.last
    Devise::Mailer.password_change(user)
  end
end
# :nocov:
