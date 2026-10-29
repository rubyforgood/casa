require "rails_helper"

RSpec.describe CaseCourtOrderPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :destroy? do
    let(:casa_org) { create(:casa_org) }
    let(:court_order) { create(:case_court_order, casa_case: create(:casa_case, casa_org: casa_org)) }
    let(:other_org_court_order) { create(:case_court_order, casa_case: create(:casa_case, casa_org: create(:casa_org))) }

    %i[casa_admin supervisor volunteer].each do |role|
      it "permits a #{role} in the court order's org" do
        expect(subject).to permit(create(role, casa_org: casa_org), court_order)
      end

      it "does not permit a #{role} from another org" do
        expect(subject).not_to permit(create(role, casa_org: casa_org), other_org_court_order)
      end
    end
  end
end
