FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| "CINA-#{n}" }
    birth_month_year_youth { 16.years.ago }
    casa_org { CasaOrg.first || create(:casa_org) }
    hearing_type # TODO make optional  move to traits
    judge # TODO make optional move to traits
    court_report_status { :not_submitted }
    case_court_orders { [] }

    trait :transition_aged do
      birth_month_year_youth { 16.years.ago }
    end

    trait :not_transition_aged do
      birth_month_year_youth { 5.years.ago }
    end

    trait :with_case_assignments do
      after(:create) do |casa_case, _|
        casa_org = casa_case.casa_org
        2.times.map do
          volunteer = create(:volunteer, casa_org: casa_org)
          create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
        end
      end
    end

    trait :with_one_court_order do
      after(:create) do |casa_case|
        casa_case.case_court_orders << build(:case_court_order)
        casa_case.save
      end
    end

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end

  trait :with_case_contacts do
    after(:create) do |casa_case|
      3.times do
        create(:case_contact, casa_case_id: casa_case.id)
      end
    end
  end
end
