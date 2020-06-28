require "rails_helper"

describe "case_contacts/edit" do

    it "is listing all the contact methods from the model" do
      assign :case_contact, create(:case_contact)

      user = build_stubbed(:user, :volunteer)
      allow(view).to receive(:current_user).and_return(user)

      contact_types = CaseContact::CONTACT_TYPES.each_with_index do |contact_type, index|
        render template: "case_contacts/edit"
        expect(rendered).to include(contact_type)
      end
    end



end
