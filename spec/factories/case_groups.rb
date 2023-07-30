FactoryBot.define do
  factory :case_group do
    casa_org { CasaOrg.first || create(:casa_org) }
    name { "A family" }

    after(:build) do |case_group, _|
      case_group.case_group_memberships.build(casa_case: create(:casa_case))
    end
  end
end
