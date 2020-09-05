require "rails_helper"

describe "case_contacts/case_contact" do
  it "Disallow case contact edit after last day of month in each quarter" do
    case_contact = create(:case_contact)
    assign :case_contact, case_contact
    assign :casa_cases, [case_contact.casa_case]

    user = build_stubbed(:volunteer)
    allow(view).to receive(:current_user).and_return(user)

    render(partial: "case_contacts/case_contact", locals: { contact: case_contact})

    # expect(rendered).to have_link(nil, href: "/case_contacts/1212/edit")
  end
end
