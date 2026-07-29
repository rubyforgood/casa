require "rails_helper"

RSpec.describe "reimbursements/index", type: :view do
  before do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
  end

  it "does not have any translation missing classes" do
    supervisor = create :supervisor
    volunteer = create :volunteer, supervisor: supervisor

    case_contact = create :case_contact, :wants_reimbursement, creator: volunteer, contact_made: true, occurred_at: 6.days.ago
    assign :reimbursements, [case_contact]
    assign :pagy, Pagy.new(count: 1, page: 1)
    assign :volunteers_for_filter, {volunteer.id => volunteer.display_name}
    assign :complete_status, false
    assign :occurred_at_filter_start_date, 1.year.ago.to_date
    render template: "reimbursements/index"

    expect(rendered).not_to have_css("span.translation_missing")
  end
end
