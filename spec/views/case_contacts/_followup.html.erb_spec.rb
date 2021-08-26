require "rails_helper"

RSpec.describe "case_contacts/_followup", type: :view do
  let(:user) { build_stubbed(:casa_admin) }

  describe "follow up icon" do
    let(:case_contact) { build_stubbed(:case_contact) }

    context "created by volunteer" do
      it "should show orange circle with an exclamation point" do
        volunteer = build_stubbed(:volunteer)
        followup = build_stubbed(:followup, case_contact: case_contact, creator: volunteer)

        render(partial: "case_contacts/followup", locals: {contact: case_contact, followup: followup})

        expect(rendered).to include("fa-exclamation-circle text-warning")
      end
    end

    context "created by admin" do
      it "should show orange circle with an exclamation point" do
        followup = build_stubbed(:followup, case_contact: case_contact, creator: user)

        render(partial: "case_contacts/followup", locals: {contact: case_contact, followup: followup})

        expect(rendered).to include("fa-exclamation-triangle text-danger")
      end
    end
  end
end
