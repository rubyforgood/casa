# Preview all emails at http://localhost:3000/rails/mailers/devise_mailer
# :nocov:
class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(User.first, "faketoken")
  end

  def invitation_instructions
    Devise::Mailer.invitation_instructions(AllCasaAdmin.first, "faketoken")
  end
end
# :nocov:
