FactoryBot.define do
  factory :supervisor, class: "Supervisor", parent: :user do
    # NOTE: see user factory for other traits, only use supervisor-specific traits here.
    sequence(:display_name) { |n| "Supervisor #{n}" }
    type { "Supervisor" }

    transient do
      volunteer_count { 0 }
    end

    supervisor_volunteers do
      Array.new(volunteer_count) do
        association(:supervisor_volunteer, supervisor: instance, casa_org:)
      end
    end

    trait :with_volunteers do
      transient { volunteer_count { 2 } }
    end
  end
end
