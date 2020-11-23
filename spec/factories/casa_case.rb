FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| "CINA-#{n}" }
    transition_aged_youth { false }
    birth_month_year_youth { 16.years.ago }
    casa_org
    hearing_type
    judge
    court_report_status { :not_submitted }

    trait :with_case_assignments do
      after(:create) do |casa_case, _|
        casa_org = casa_case.casa_org
        2.times.map do
          volunteer = create(:volunteer, casa_org: casa_org)
          create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
        end
      end
    end

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
