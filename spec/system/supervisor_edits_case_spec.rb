require "rails_helper"

RSpec.describe "supervisor edits case", type: :system do
  let(:casa_org) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }
  let!(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
  let!(:contact_type_1) { create(:contact_type, name: "Youth", contact_type_group: contact_type_group ) }
  let!(:contact_type_2) { create(:contact_type, name: "Supervisor", contact_type_group: contact_type_group) }

  before do
    sign_in supervisor
    visit edit_casa_case_path(casa_case)
  end

  it "edits case" do
    has_no_checked_field? :court_report_submitted
    check "Court report submitted"
    check "Youth"
    click_on "Update CASA Case"
    has_checked_field? :court_report_submitted
    has_checked_field? "Youth"
    has_no_checked_field? "Supervisor"
  end
end
