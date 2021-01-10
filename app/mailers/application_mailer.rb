class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@#{ENV["DOMAIN"]}"
  layout "mailer"
end
