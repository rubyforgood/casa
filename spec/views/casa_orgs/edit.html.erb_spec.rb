require "rails_helper"

RSpec.describe "casa_org/edit", type: :view do
  before do
    assign(:contact_type_groups, [])
    assign(:contact_types, [])
    assign(:hearing_types, [])
    assign(:judges, [])
    assign(:sent_emails, [])

    sign_in build_stubbed(:casa_admin)
  end

  it "has casa org edit page text" do
    organization = create(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)

    render template: "casa_org/edit"

    expect(rendered).to have_text "Editing CASA Organization"
    expect(rendered).to_not have_text "sign in before continuing"
  end

  it "has contact types content" do
    organization = create(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    contact_type = create(:contact_type, name: "Contact type 1")
    assign(:contact_types, [contact_type])

    render template: "casa_org/edit"

    expect(rendered).to have_text("Contact type 1")
    expect(rendered).to have_text(contact_type.name)
    expect(rendered).to have_table("contact-types",
      with_rows:
      [
        ["Contact type 1", "Yes", "Edit"]
      ]
    )
  end

  it "has contact type groups content" do
    organization = create(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    contact_type_group = create(:contact_type_group,  casa_org: organization, name: "Contact type group 1")
    assign(:contact_type_groups, [contact_type_group])

    render template: "casa_org/edit"

    expect(rendered).to have_text("Contact type group 1")
    expect(rendered).to have_text(contact_type_group.name)
    expect(rendered).to have_table("contact-type-groups",
      with_rows: [
        ["Contact type group 1", "Yes", "Edit"]
      ]
    )
  end

  it "has hearing types content" do
    organization = create(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    hearing_type = create(:hearing_type, casa_org: organization, name: "Hearing type 1")
    assign(:hearing_types, [hearing_type])

    render template: "casa_org/edit"

    expect(rendered).to have_text("Hearing type 1")
    expect(rendered).to have_table("hearing-types",
      with_rows:
      [
        ["Hearing type 1", "Yes", "Edit"]
      ]
    )
  end

  it "has judge content" do
    organization = create(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    judge = create(:judge, casa_org: organization, name: "Joey Tom")
    assign(:judges, [judge])

    render template: "casa_org/edit"

    expect(rendered).to have_text(judge.name)
  end

  it "does not show download prompt with no custom template" do
    organization = create :casa_org
    allow(view).to receive(:current_organization).and_return(organization)

    render template: "casa_org/edit"

    expect(rendered).not_to have_text("Download Current Template")
  end

  it "has sent emails content" do
    organization = create :casa_org
    admin = create(:casa_admin, casa_org: organization)
    allow(view).to receive(:current_organization).and_return(organization)

    sent_email = create(:sent_email, user: admin, created_at: Time.zone.local(2021, 1, 2, 12, 30, 0))
    assign(:sent_emails, [sent_email])

    render template: "casa_org/edit"

    expect(rendered).to have_text(sent_email.sent_address)
    expect(rendered).to have_table("sent-emails",
      with_rows: [
        ["Mailer Type", "Mail Action Category", admin.email, "12:30pm 02 Jan 2021"]
      ]
    )
  end

  context "with a template uploaded" do
    it "renders a prompt to download current template" do
      organization = create :casa_org
      allow(view).to receive(:current_organization).and_return(organization)

      organization.court_report_template.attach(io: File.open("#{Rails.root}/app/documents/templates/default_report_template.docx"), filename: 'default_report_template
.docx', content_type: "application/docx")

      render template: "casa_org/edit"

      expect(rendered).to have_text("Download Current Template")
    end
  end
end
