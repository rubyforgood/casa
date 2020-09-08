FactoryBot.define do
  factory :all_casa_admin, class: "AllCasaAdmin" do
    sequence(:email) { |n| "email#{n}@example.com" }
    password { "123456" }
    password_confirmation { "123456" }
  end
end
