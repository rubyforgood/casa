FactoryBot.define do
  factory :sent_email do
    association :user, factory: :user
    casa_org { CasaOrg.first || create(:casa_org) }
    mailer_type { "Mailer Type" }
    category { "Mail Action Category" }
    sent_address { user.email }
  end
end
