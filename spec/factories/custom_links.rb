FactoryBot.define do
  factory :custom_link do
    text { 'Example Link' }
    url { 'http://example.com' }
    association :casa_org
  end
end
