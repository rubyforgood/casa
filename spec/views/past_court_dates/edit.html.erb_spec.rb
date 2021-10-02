require "rails_helper"

RSpec.describe "past_court_dates/edit", type: :view do
  subject { render template: "past_court_dates/edit" }

  let(:organization) { create(:casa_org) }
  let(:user) { build_stubbed(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:past_court_date) { create(:past_court_date, :with_court_details, casa_case: casa_case) }
  let(:court_order) { past_court_date.case_court_orders.first }
  let(:implementation_status_name) do
    "past_court_date_case_court_orders_attributes_0_implementation_status"
  end
  let(:implementation_status) do
    court_order.implementation_status.humanize
  end

  before do
    assign :casa_case, casa_case
    assign :past_court_date, past_court_date

    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  it { is_expected.to have_select("past_court_date_judge_id", selected: past_court_date.judge.name) }
  it { is_expected.to have_select("past_court_date_hearing_type_id", selected: past_court_date.hearing_type.name) }
  it { is_expected.to have_selector("textarea", text: court_order.mandate_text) }
  it { is_expected.to have_select(implementation_status_name, selected: implementation_status) }
  it { is_expected.to have_selector(".btn-primary") }
end
