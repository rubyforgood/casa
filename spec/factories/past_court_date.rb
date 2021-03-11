FactoryBot.define do
  factory :past_court_date, class: "PastCourtDate" do
    casa_case
    date { Time.now }
  end
end
