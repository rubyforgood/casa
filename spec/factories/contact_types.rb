FactoryBot.define do
  factory :contact_type do
    transient do
      casa_org { nil }
    end

    sequence(:name) { |n| "Type #{n}" }

    contact_type_group do
      if casa_org.present?
        association(:contact_type_group, casa_org:)
      else
        association(:contact_type_group)
      end
    end
  end
end
