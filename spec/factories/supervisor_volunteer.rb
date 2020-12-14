FactoryBot.define do
  factory :supervisor_volunteer do
    supervisor { create(:supervisor) }
    volunteer { create(:volunteer) }

    transient do
      casa_org { CasaOrg.first || create(:casa_org) }
    end

    trait :inactive do
      is_active { false }
    end
  end
end
