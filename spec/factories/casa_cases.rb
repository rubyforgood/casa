FactoryBot.define do
  factory :casa_case do
    sequence(:case_number) { |n| "CINA-#{n}" }
    birth_month_year_youth { 16.years.ago }
    casa_org { CasaOrg.first || create(:casa_org) }
    court_report_status { :not_submitted }
    case_court_orders { [] }

    trait :pre_transition do
      birth_month_year_youth { 13.years.ago }
    end

    trait :with_one_case_assignment do
      after(:create) do |casa_case, _|
        casa_org = casa_case.casa_org
        volunteer = create(:volunteer, casa_org: casa_org)
        create(:case_assignment, casa_case: casa_case, volunteer: volunteer)
      end
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

  trait :with_casa_case_contact_types do
    after(:create) do |casa_case, _|
      casa_org = casa_case.casa_org
      2.times.map do
        contact_type_group = create(:contact_type_group, casa_org: casa_org)
        contact_type = create(:contact_type, contact_type_group: contact_type_group)
        create(:casa_case_contact_type, casa_case: casa_case, contact_type: contact_type)
      end
    end
  end

  trait :with_upcoming_court_date do
    after(:create) do |casa_case|
      create(:court_date, casa_case: casa_case, date: Date.tomorrow)
    end
  end

  trait :with_past_court_date do
    after(:create) do |casa_case|
      create(:court_date, casa_case: casa_case, date: Date.yesterday)
    end
  end

  trait :with_placement do
    after(:create) do |casa_case|
      create(:placement, casa_case: casa_case, placement_started_at: Date.tomorrow)
    end
  end
end
