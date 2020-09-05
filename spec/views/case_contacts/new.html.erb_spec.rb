require "rails_helper"

describe "case_contacts/new" do

  it "displays current time in the occurred at form field" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]

    user = build_stubbed(:volunteer)
    allow(view).to receive(:current_user).and_return(user)

    render template: "case_contacts/new"
    expect(rendered).to include(Time.zone.now.strftime("%Y-%m-%d"))
  end

  it "displays the notes text area field" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]

    user = build_stubbed(:volunteer)
    allow(view).to receive(:current_user).and_return(user)

    render template: "case_contacts/new"
    expect(rendered).to have_selector("textarea", id: "case_contact_notes")
  end

  fit "has a button to Return to Dashboard" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]

    user = build_stubbed(:volunteer)
    allow(view).to receive(:current_user).and_return(user)

    render template: "case_contacts/new"
    expect(rendered).to have_selector("a", text: "Return to Dashboard")
  end
end
