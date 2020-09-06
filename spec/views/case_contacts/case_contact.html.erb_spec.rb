require "rails_helper"

describe "case_contacts/case_contact" do
  it "allows edit before quarter-end" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]

    user = build_stubbed(:supervisor)
    allow(view).to receive(:current_user).and_return(user)

    render(partial: "case_contacts/case_contact", locals: { contact: case_contact})
    expect(rendered).to have_link(nil, href: "/case_contacts/#{case_contact.id}/edit")
  end

  it "disallows edit before quarter-end" do
    case_contact = create(:case_contact, occured_at: Time.zone.now - 1.year)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]

    user = build_stubbed(:supervisor)
    allow(view).to receive(:current_user).and_return(user)

    render(partial: "case_contacts/case_contact", locals: { contact: case_contact})
    expect(rendered).to have_no_link(nil, href: "/case_contacts/#{case_contact.id}/edit")
  end
end
