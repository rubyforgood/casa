FactoryBot.define do
  factory :court_date, class: "CourtDate" do
    transient do
      casa_org do
        @overrides[:casa_case].try(:casa_org) ||
          @overrides[:hearing_type].try(:casa_org) ||
          @overrides[:judge].try(:casa_org) ||
          association(:casa_org)
      end
    end

    casa_case { association :casa_case, casa_org: }

    date { 1.week.ago }

    trait :with_court_details do
      with_judge
      with_hearing_type
      with_court_order
    end

    trait(:with_judge) do
      judge { association :judge, casa_org: }
    end

    trait(:with_hearing_type) do
      hearing_type { association :hearing_type, casa_org: }
    end

    trait :with_court_order do
      case_court_orders do
        Array.new(1) do
          association(:case_court_order, casa_case:)
        end
      end
    end
  end
end
