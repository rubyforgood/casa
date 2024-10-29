FactoryBot.define do
  factory :supervisor_volunteer do
    transient do
      casa_org do
        @overrides[:volunteer].try(:casa_org) ||
          @overrides[:supervisor].try(:casa_org) ||
          association(:casa_org)
      end
    end

    is_active { true }

    supervisor { association :supervisor, casa_org: }
    volunteer { association :volunteer, casa_org: }

    trait :inactive do
      is_active { false }
    end
  end
end
