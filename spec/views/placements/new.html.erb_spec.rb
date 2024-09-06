require "rails_helper"

RSpec.describe "placements/new", type: :view do
  subject { render template: "placements/new" }

  before do
    assign :casa_case, casa_case
    assign :placement, Placement.new

    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  let(:user) { build_stubbed(:casa_admin) }
  let(:casa_case) { create(:casa_case) }

  it { is_expected.to have_selector("h1", text: "New Placement") }
  it { is_expected.to have_selector("h6", text: casa_case.case_number) }
  it { is_expected.to have_link(casa_case.case_number, href: "/casa_cases/#{casa_case.case_number.parameterize}") }
  it { is_expected.to have_selector(".primary-btn") }
end
