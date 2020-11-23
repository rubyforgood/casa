FactoryBot.define do
  factory :case_assignment do
    transient do
      casa_org { create(:casa_org) }
    end

    is_active { true }

    casa_case do
      create(:casa_case, casa_org: @overrides[:volunteer].try(:casa_org) || casa_org)
    end

    volunteer do
      create(:volunteer, casa_org: @overrides[:casa_case].try(:casa_org) || casa_org)
    end
  end
end
