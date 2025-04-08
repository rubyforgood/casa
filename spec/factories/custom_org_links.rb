FactoryBot.define do
  factory :custom_org_link do
    casa_org
    text { "Custom Link Text" }
    url { "https://custom.link" }
    active { true }
  end
end
