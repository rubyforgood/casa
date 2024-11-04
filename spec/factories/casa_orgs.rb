FactoryBot.define do
  factory :casa_org do
    sequence(:name) { |n| "CASA Org #{n}" }
    sequence(:display_name) { |n| "CASA Org #{n}" }
    address { "123 Main St" }
    footer_links { [["www.example.com", "First Link"], ["www.foobar.com", "Second Link"]] }
    twilio_account_sid { "articuno34" }
    twilio_api_key_secret { "open sesame" }
    twilio_api_key_sid { "Aladdin" }
    twilio_phone_number { "+15555555555" }

    trait :with_logo do
      logo { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/org_logo.jpeg")) }
    end

    trait :all_reimbursements_enabled do
      additional_expenses_enabled { true }
      show_driving_reimbursement { true }
    end

    trait :with_placement_types do
      transient { placement_names { ["Reunification", "Adoption", "Foster Care", "Kinship"] } }

      after(:create) do |org, evaluator|
        evaluator.placement_names.each do |name|
          org.placement_types.create!(name: name)
        end
      end
    end
  end
end
