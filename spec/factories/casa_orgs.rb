FactoryBot.define do
  factory :casa_org do
    transient do
      placement_names { [] }
    end

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
      placement_names { ["Reunification", "Adoption", "Foster Care", "Kinship"] }

      placement_types do
        Array.wrap(placement_names).map do |name|
          association(:placement_type, name:, casa_org: instance)
        end
      end
    end
  end
end
