FactoryBot.define do
  factory :casa_org_logo do
    casa_org
    url { "media/src/images/favicon-16x16.png" }
    alt_text { "alt text" }
    size { "10x10" }
  end
end
