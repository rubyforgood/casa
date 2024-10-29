FactoryBot.define do
  factory :casa_case_contact_type do
    transient do
      casa_org do
        @overrides[:casa_case].try(:casa_org) ||
          @overrides[:contact_type].try(:contact_type_group).try(:casa_org) ||
          association(:casa_org)
      end
    end

    contact_type { association(:contact_type, casa_org:) }
    casa_case { association(:casa_case, casa_org:) }
  end
end
