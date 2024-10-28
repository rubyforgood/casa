FactoryBot.define do
  factory :sent_email do
    user
    casa_org { user.casa_org }
    mailer_type { "Mailer Type" }
    category { "Mail Action Category" }
    sent_address { user.email }
  end
end
