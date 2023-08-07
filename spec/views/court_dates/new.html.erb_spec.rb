require "rails_helper"

RSpec.describe "court_dates/new", type: :view do
  subject { render template: "court_dates/new" }

  before do
    assign :casa_case, casa_case
    assign :court_date, CourtDate.new

    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  let(:user) { build_stubbed(:casa_admin) }
  let(:casa_case) { create(:casa_case) }

  it { is_expected.to have_selector("h1", text: "New Court Date") }
  it { is_expected.to have_selector("h6", text: casa_case.case_number) }
  it { is_expected.to have_link(casa_case.case_number, href: "/casa_cases/#{casa_case.case_number.parameterize}") }
  it { is_expected.to have_selector(".primary-btn") }
end
