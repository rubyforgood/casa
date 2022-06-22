FactoryBot.define do
  factory :patch_note_group do
    sequence :value do |n| # Factory with default value includes no users
      n.to_s
    end

    trait :all_users do
      value { "Admin+Supervisor+Volunteer" }
    end

    trait :only_supervisors_and_admins do
      value { "Admin+Supervisor" }
    end
  end
end
