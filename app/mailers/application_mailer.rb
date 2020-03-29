class ApplicationMailer < ActionMailer::Base # rubocop:todo Style/Documentation
  default from: 'from@example.com'
  layout 'mailer'
end
