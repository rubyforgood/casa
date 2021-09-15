FactoryBot.define do
  factory :past_court_date, class: "PastCourtDate" do
    casa_case
    date { 1.week.ago }

    trait :with_court_details do
      with_judge
      with_hearing_type
      with_court_mandate
    end

    trait(:with_judge) { judge }
    trait(:with_hearing_type) { hearing_type }

    trait :with_court_mandate do
      after(:create) do |past_court_date|
        past_court_date.case_court_mandates << build(:case_court_mandate, casa_case: past_court_date.casa_case)
        past_court_date.save
      end
    end
  end
end
