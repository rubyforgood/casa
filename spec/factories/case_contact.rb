FactoryBot.define do
  factory :case_contact do
    association :creator, factory: :user
    casa_case

    contact_types { [create(:contact_type)] }
    duration_minutes { 60 }
    occurred_at { Time.zone.now }
    contact_made { false }
    medium_type { CaseContact::CONTACT_MEDIUMS.first }
    want_driving_reimbursement { false }
    deleted_at { nil }

    trait :multi_line_note do
      notes { "line1\nline2\nline3" }
    end

    trait :long_note do
      notes { "1234567890 " * 11 } # longer than NOTES_CHARACTER_LIMIT
    end

    trait :miles_driven_no_reimbursement do
      miles_driven { 20 }
    end

    trait :wants_reimbursement do
      miles_driven { 456 }
      want_driving_reimbursement { true }
    end
  end
end
