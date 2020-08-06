class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
  def initialize
    @send_in_blue = SibApiV3Sdk::SMTPApi.new
  end
end
