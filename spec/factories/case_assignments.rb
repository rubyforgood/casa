FactoryBot.define do
  factory :case_assignment do
    transient do
      casa_org do
        case_org = @overrides[:casa_case].try(:casa_org)
        volunteer_org = @overrides[:volunteer].try(:casa_org)
        case_org || volunteer_org || CasaOrg.first || create(:casa_org)
      end
    end

    active { true }
    allow_reimbursement { true }

    casa_case { association :casa_case, casa_org: }
    volunteer { association :volunteer, casa_org: }

    trait :pre_transition do
      casa_case { association :casa_case, :pre_transition, casa_org: }
    end

    trait :disallow_reimbursement do
      allow_reimbursement { false }
    end

    trait :inactive do
      active { false }
    end
  end
end
