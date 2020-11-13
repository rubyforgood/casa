FactoryBot.define do
  factory :supervisor_volunteer do
    transient do
      casa_org { create(:casa_org) }
    end

    supervisor do
      create(:supervisor, casa_org: @overrides[:volunteer].present? ? @overrides[:volunteer].casa_org : casa_org)
    end

    volunteer do
      create(:volunteer, casa_org: @overrides[:supervisor].present? ? @overrides[:supervisor].casa_org : casa_org)
    end

    trait :inactive do
      is_active { false }
    end
  end
end
