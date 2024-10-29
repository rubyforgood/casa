FactoryBot.define do
  factory :volunteer, class: "Volunteer", parent: :user do
    # NOTE: see user factory for other traits, only use volunteer-specific traits here.
    transient do
      supervisor { nil }
      case_count { 0 }
      contacts_per_case { 0 }
      casa_cases { nil }
    end

    sequence(:display_name) { |n| "Volunteer #{n}" }
    type { "Volunteer" }
    casa_org do
      @overrides[:supervisor].try(:casa_org) ||
        @overrides[:casa_cases].try(:first).try(:casa_org) ||
        association(:casa_org)
    end

    supervisor_volunteer do
      if supervisor
        association(:supervisor_volunteer, volunteer: instance, supervisor:, casa_org:)
      end
    end

    case_assignments do
      if casa_cases.nil?
        Array.new(case_count) { association(:case_assignment, volunteer: instance, casa_org:) }
      else
        Array.wrap(casa_cases).map do |casa_case|
          association(:case_assignment, volunteer: instance, casa_case:)
        end
      end
    end

    case_contacts do
      case_assignments.map { |ca|
        Array.new(contacts_per_case) { association(:case_contact, creator: ca.volunteer, casa_case: ca.casa_case) }
      }.flatten
    end

    trait :with_casa_cases do
      case_count { 2 }
    end

    trait :with_single_case do
      case_count { 1 }
    end

    trait :with_pretransition_age_case do
      case_count { 1 }
      case_assignments do
        Array.new(case_count) { association(:case_assignment, :pre_transition, volunteer: instance, casa_org:) }
      end
    end

    trait :with_cases_and_contacts do
      with_casa_cases
      with_case_contact
    end

    trait :with_assigned_supervisor do
      supervisor { association(:supervisor, casa_org:) }
    end

    trait :with_inactive_supervisor do
      supervisor { association(:supervisor, casa_org:) }

      supervisor_volunteer do
        if supervisor
          association(:supervisor_volunteer, :inactive, volunteer: instance, supervisor:, casa_org:)
        end
      end
    end

    trait :with_case_contact do
      case_count { 1 }
      with_case_contacts
    end

    trait :with_case_contacts do
      contacts_per_case { 1 }
    end

    trait :with_case_contact_wants_driving_reimbursement do
      case_count { 1 }
      contacts_per_case { 1 }

      case_contacts do
        case_assignments.map { |assignment|
          Array.new(contacts_per_case) { association(:case_contact, :wants_reimbursement, creator: instance, casa_case: assignment.casa_case) }
        }.flatten
      end
    end

    trait :with_disallow_reimbursement do
      case_count { 1 }

      case_assignments do
        Array.new(case_count) { association(:case_assignment, :disallow_reimbursement, volunteer: instance, casa_org:) }
      end
    end
  end
end
