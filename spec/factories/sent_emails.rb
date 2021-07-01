FactoryBot.define do
  factory :sent_email do
    association :user, factory: :user
    casa_org { CasaOrg.first || create(:casa_org) }
    mailer_type { "MyString" }
    category { "MyString" }
    sent_address { "MyString" }
  end
end
