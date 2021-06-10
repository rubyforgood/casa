class ApplicationMailer < ActionMailer::Base
  address = Mail::Address.new "no-reply@#{ENV["DOMAIN"] || "example.com"}"
  address.display_name = "CASA Admin"

  default from: address.format
  layout "mailer"

  def mail(headers = {}, &block)
    SentEmail.create(
      casa_org: @casa_organization,
      sent_to: @user, 
      sent_address: @user.email, 
      mailer_type: self.class.to_s,
      category: @category || "other",
      subject: @subject || headers[:subject]
    ) 
    super
  end
end
