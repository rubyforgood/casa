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

  specify do
    expect(subject).to have_css("h1", text: "New Court Date")
    expect(subject).to have_css("h6", text: casa_case.case_number)
    expect(subject).to have_link(casa_case.case_number, href: "/casa_cases/#{casa_case.case_number.parameterize}")
    expect(subject).to have_css(".primary-btn")
  end
end
