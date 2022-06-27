FactoryBot.define do
  factory :all_casa_admin, class: "AllCasaAdmin" do
    sequence(:email) { |n| "email#{n}@example.com" }
    password { "12345678" }
    password_confirmation { "12345678" }
  end
end
