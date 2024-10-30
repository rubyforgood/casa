FactoryBot.define do
  factory :casa_case do
    casa_org do
      @overrides[:volunteers].try(:first).try(:casa_org) ||
        association(:casa_org)
    end
    sequence(:case_number) { |n| "CINA-#{n}" }
    birth_month_year_youth { 16.years.ago }
    court_report_status { :not_submitted }
    case_court_orders { [] }

    transient do
      volunteer { nil }
      volunteers { Array.wrap(volunteer) }
      volunteer_count { 0 }
    end

    case_assignments do
      if volunteers&.any?
        volunteers.map do |volunteer|
          association(:case_assignment, casa_case: instance, volunteer:)
        end
      elsif volunteer_count.positive?
        Array.new(volunteer_count) do
          association(:case_assignment, casa_case: instance)
        end
      else
        []
      end
    end

    trait :pre_transition do
      birth_month_year_youth { 13.years.ago }
    end

    trait :with_one_case_assignment do
      volunteer_count { 1 }
    end

    trait :with_case_assignments do
      volunteer_count { 2 }
    end

    trait :with_one_court_order do
      case_court_orders do
        Array.new(1) { association(:case_court_order, casa_case: instance) }
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
    case_contacts do
      Array.new(3) { association(:case_contact, casa_case: instance) }
    end
  end

  trait :with_casa_case_contact_types do
    casa_case_contact_types do
      Array.new(2) do
        association(:casa_case_contact_type, casa_case: instance)
      end
    end
  end

  trait :with_upcoming_court_date do
    court_dates do
      Array.new(1) { association(:court_date, casa_case: instance, date: Date.tomorrow) }
    end
  end

  trait :with_past_court_date do
    court_dates do
      Array.new(1) { association(:court_date, casa_case: instance, date: Date.yesterday) }
    end
  end

  trait :with_past_and_future_court_dates do
    court_dates do
      [
        association(:court_date, casa_case: instance, date: Date.yesterday),
        association(:court_date, casa_case: instance, date: Date.tomorrow)
      ]
    end
  end

  trait :with_placement do
    placements do
      Array.new(1) { association(:placement, casa_case: instance, placement_started_at: Date.tomorrow) }
    end
  end
end
