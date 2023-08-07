FactoryBot.define do
  factory :case_assignment do
    transient do
      casa_org { CasaOrg.first || create(:casa_org) }
      pre_transition { false }
    end

    active { true }
    allow_reimbursement { true }

    casa_case do
      if pre_transition
        create(:casa_case, :pre_transition, casa_org: @overrides[:volunteer].try(:casa_org) || casa_org)
      else
        create(:casa_case, casa_org: @overrides[:volunteer].try(:casa_org) || casa_org)
      end
    end

    volunteer do
      create(:volunteer, casa_org: @overrides[:casa_case].try(:casa_org) || casa_org)
    end

    trait :disallow_reimbursement do
      allow_reimbursement { false }
    end

    trait :inactive do
      active { false }
    end
  end
end
