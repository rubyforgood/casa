require "rails_helper"

RSpec.describe CaseContactPresenter do
  let(:organization) { build(:casa_org) }
  let(:user) { create(:casa_admin, casa_org: organization) }
  let(:case_contacts) { create_list(:case_contact, 5, casa_case: casa_case) }
  let(:presenter) { described_class.new(case_contacts) }

  before do
    allow_any_instance_of(described_class).to receive(:current_user).and_return(user)
    allow_any_instance_of(described_class).to receive(:current_organization).and_return(organization)
  end

  describe "#display_case_number" do
    context "with transition aged youth" do
      let(:casa_case) { create(:casa_case, birth_month_year_youth: 15.years.ago, casa_org: organization) }

      it "displays the case number with correct icon" do
        casa_case_id = casa_case.id
        case_number = casa_case.case_number

        expect(presenter.display_case_number(casa_case_id)).to eql("🦋 #{case_number}")
      end

      it "does not error when case number is nil" do
        expect(presenter.display_case_number(nil)).to eql("")
      end
    end

    context "with non-transition aged youth" do
      let(:casa_case) { create(:casa_case, birth_month_year_youth: 12.years.ago, casa_org: organization) }

      it "displays the case number with correct icon" do
        casa_case_id = casa_case.id
        case_number = casa_case.case_number

        expect(presenter.display_case_number(casa_case_id)).to eql("🐛 #{case_number}")
      end

      it "does not error when case number is nil" do
        expect(presenter.display_case_number(nil)).to eql("")
      end
    end
  end
end
