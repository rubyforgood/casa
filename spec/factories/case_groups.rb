FactoryBot.define do
  factory :case_group do
    transient do
      case_count { 1 }
    end
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:name) { |n| "Family #{n}" }

    after(:build) do |case_group, evaluator|
      if case_group.case_group_memberships.empty?
        evaluator.case_count.times do
          case_group.case_group_memberships.build(casa_case: create(:casa_case))
        end
      end
    end
  end
end
