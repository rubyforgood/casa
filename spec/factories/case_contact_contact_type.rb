FactoryBot.define do
    factory :case_contact_contact_type do
        contact_type_id { create(:contact_type).id }
        case_contact_id { create(:case_contact).id }
    end
  end