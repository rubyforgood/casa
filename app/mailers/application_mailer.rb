class ApplicationMailer < ActionMailer::Base
  address = Mail::Address.new "no-reply@#{ENV["DOMAIN"] || "example.com"}"
  address.display_name = "CASA Admin"

  default from: address.format
  layout "mailer"
end
