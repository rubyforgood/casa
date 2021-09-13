require "rails_helper"

RSpec.describe "past_court_dates/new", type: :view do
  subject { render template: "past_court_dates/new" }

  before do
    assign :casa_case, casa_case
    assign :past_court_date, PastCourtDate.new

    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  let(:user) { build_stubbed(:casa_admin) }
  let(:casa_case) { create(:casa_case) }

  it { is_expected.to have_selector("h1", text: "New Past Court Date") }
  it { is_expected.to have_selector("h6", text: casa_case.case_number) }
  it { is_expected.to have_selector(".btn-primary") }
end
