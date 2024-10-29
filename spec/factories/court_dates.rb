FactoryBot.define do
  factory :court_date, class: "CourtDate" do
    casa_case
    date { 1.week.ago }

    trait :with_court_details do
      with_judge
      with_hearing_type
      with_court_order
    end

    trait(:with_judge) { judge }
    trait(:with_hearing_type) { hearing_type }

    trait :with_court_order do
      case_court_orders do
        Array.new(1) do
          association(:case_court_order, casa_case:)
        end
      end
    end
  end
end
