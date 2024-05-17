FactoryBot.define do
  factory :case_group do
    casa_org { CasaOrg.first || create(:casa_org) }
    sequence(:name) { |n| "Family #{n}" }

    after(:build) do |case_group, _|
      if case_group.case_group_memberships.empty?
        case_group.case_group_memberships.build(casa_case: create(:casa_case))
      end
    end
  end
end
