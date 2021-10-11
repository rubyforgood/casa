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
      after(:create) do |court_date|
        court_date.case_court_orders << build(:case_court_order, casa_case: court_date.casa_case)
        court_date.save
      end
    end
  end
end
