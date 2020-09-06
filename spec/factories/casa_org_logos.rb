FactoryBot.define do
  factory :casa_org_logo do
    casa_org
    url { "www.example.com" }
    alt_text { "alt text" }
    size { "10x10" }
  end
end
