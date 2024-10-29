FactoryBot.define do
  # NOTE: FactoryBot automatically creates traits for a model's enum attributes
  # https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#enum-traits
  # For example, CaseContact status enum includes `active: "active"` state, so following already defined:
  # trait :active do
  #   status { "active" }
  # end
  # ALSO, we can use any trait within other traits:
  # https://github.com/thoughtbot/factory_bot/blob/main/GETTING_STARTED.md#traits-within-traits
  # So, rather than `status { "active" }` - use enum trait like so:
  factory :case_contact do
    transient do
      casa_org do
        @overrides[:casa_case].try(:casa_org) ||
          @overrides[:creator].try(:casa_org) ||
          @overrides[:contact_types]&.first.try(:casa_org) ||
          CasaOrg.first ||
          association(:casa_org)
      end
    end

    active # use the `:active` enum trait
    duration_minutes { 60 }
    occurred_at { Time.zone.today }
    contact_made { false }
    medium_type { CaseContact::CONTACT_MEDIUMS.first }
    want_driving_reimbursement { false }
    deleted_at { nil }
    metadata { {} }

    creator { association :volunteer, casa_org: }
    casa_case { association :casa_case, casa_org: }
    contact_types { [association(:contact_type, casa_org:)] }
    draft_case_ids { [casa_case&.id] }

    trait :multi_line_note do
      notes { "line1\nline2\nline3" }
    end

    trait :long_note do
      notes { "1234567890 " * 11 } # longer than NOTES_CHARACTER_LIMIT
    end

    trait :miles_driven_no_reimbursement do
      miles_driven { 20 }
      want_driving_reimbursement { false }
    end

    trait :wants_reimbursement do
      miles_driven { 456 }
      want_driving_reimbursement { true }
      volunteer_address { "123 Contact Factory St" }
    end

    trait :started_status do
      started # enum trait

      casa_case { nil }
      contact_types { [] }
      draft_case_ids { [] }
      medium_type { nil }
      occurred_at { nil }
      duration_minutes { nil }
      notes { nil }
      miles_driven { 0 }
    end

    trait :details_status do
      details # enum trait

      casa_case { nil }
      draft_case_ids { [1] }
      notes { nil }
      miles_driven { 0 }
    end

    trait :notes_status do
      notes # enum trait

      casa_case { nil }
      draft_case_ids { [1] }
      miles_driven { 0 }
    end

    trait :expenses_status do
      expenses # enum trait

      draft_case_ids { [1] }
    end
  end
end
