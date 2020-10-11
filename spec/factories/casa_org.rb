FactoryBot.define do
  factory :casa_org do
    sequence(:name) { |n| "CASA Org #{n}" }
    sequence(:display_name) { |n| "CASA Org #{n}" }
    address { "123 Main St" }
    footer_links { [["www.example.com", "First Link"], ["www.foobar.com", "Second Link"]] }
  end
end
