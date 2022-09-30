require "rails_helper"

RSpec.describe "reimbursements/index", type: :view do
  before do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
  end

  it "should not have any translation missing classes" do
    supervisor = create :supervisor
    volunteer = create :volunteer, supervisor: supervisor

    case_contact = create :case_contact, :wants_reimbursement, creator: volunteer, contact_made: true, occurred_at: Time.current - 6.days
    assign :reimbursements, [case_contact]
    assign :grouped_reimbursements, []
    assign :volunteers_for_filter, []
    render template: "reimbursements/index"

    expect(rendered).not_to have_css("span.translation_missing")
  end
end
