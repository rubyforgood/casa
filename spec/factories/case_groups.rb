FactoryBot.define do
  factory :case_group do
    transient do
      case_count { 1 }
      casa_cases { nil }
    end
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:name) { |n| "Family #{n}" }

    after(:build) do |case_group, evaluator|
      casa_cases = if evaluator.casa_cases.present?
        evaluator.casa_cases
      elsif case_group.case_group_memberships.empty?
        build_list(:casa_case, evaluator.case_count, casa_org: case_group.casa_org)
      else
        []
      end
      casa_cases.each do |casa_case|
        case_group.case_group_memberships.build(casa_case: casa_case)
      end
    end
  end
end
