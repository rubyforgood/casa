FactoryBot.define do
  factory :volunteer, class: "Volunteer", parent: :user do
    casa_org do
      @overrides[:casa_org] || @overrides[:supervisor].try(:casa_org) || create(:casa_org)
    end

    trait :inactive do
      active { false }
    end

    trait :with_casa_cases do
      after(:create) do |user, _|
        create(:case_assignment, casa_case: create(:casa_case, casa_org: user.casa_org), volunteer: user)
        create(:case_assignment, casa_case: create(:casa_case, casa_org: user.casa_org), volunteer: user)
      end
    end

    trait :with_cases_and_contacts do
      after(:create) do |user, _|
        assignment1 = create :case_assignment, casa_case: create(:casa_case, casa_org: user.casa_org, transition_aged_youth: false, court_date: 1.month.ago), volunteer: user
        create :case_assignment, casa_case: create(:casa_case, casa_org: user.casa_org, transition_aged_youth: true, birth_month_year_youth: 10.years.ago, court_date: 1.month.ago), volunteer: user
        contact = create :case_contact, creator: user, casa_case: assignment1.casa_case
        contact_types = create_list :contact_type, 3, contact_type_group: create(:contact_type_group, casa_org: user.casa_org)
        3.times do
          CaseContactContactType.create(case_contact: contact, contact_type: contact_types.pop)
        end
      end
    end

    trait :with_assigned_supervisor do
      after(:create) do |user, _|
        create(:supervisor_volunteer, volunteer: user)
      end
    end

    trait :with_inactive_supervisor do
      after(:create) do |user, _|
        create(:supervisor_volunteer, :inactive, volunteer: user)
      end
    end

    trait :with_inactive_supervisor_assignment do
      after(:create) do |user, _|
        create(:supervisor_volunteer, :inactive, volunteer: user)
      end
    end
  end
end
