FactoryBot.define do
  factory :sent_email do
    mailer_type { "MyString" }
    category { "MyString" }
    sent_address { "MyString" }
  end
end
