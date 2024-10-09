require "rails_helper"

RSpec.describe "casa_org/edit", type: :view do
  before do
    assign(:contact_type_groups, [])
    assign(:contact_types, [])
    assign(:hearing_types, [])
    assign(:judges, [])
    assign(:learning_hour_types, [])
    assign(:learning_hour_topics, [])
    assign(:sent_emails, [])
    assign(:contact_topics, [])

    sign_in build_stubbed(:casa_admin)
  end

  it "has casa org edit page text" do
    organization = build_stubbed(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)

    render template: "casa_org/edit"

    expect(rendered).to have_text "Editing CASA Organization"
    expect(rendered).to_not have_text "sign in before continuing"
    expect(rendered).to have_selector("input[required=required]", id: "casa_org_name")
  end

  it "has contact topic content" do
    organization = build_stubbed(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    contact_topic = build_stubbed(:contact_topic, question: "Test Question", details: "Test details")
    assign(:contact_topics, [contact_topic])

    render template: "casa_org/edit"

    expect(rendered).to have_text("Test Question")
    expect(rendered).to have_text("Test details")
    expect(rendered).to have_table("contact-topics",
      with_rows:
      [
        ["Test Question", "Test details", "Edit"]
      ])
  end

  it "has contact types content" do
    organization = build_stubbed(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    contact_type = build_stubbed(:contact_type, name: "Contact type 1")
    assign(:contact_types, [contact_type])

    render template: "casa_org/edit"

    expect(rendered).to have_text("Contact type 1")
    expect(rendered).to have_text(contact_type.name)
    expect(rendered).to have_table("contact-types",
      with_rows:
      [
        ["Contact type 1", "Yes", "Edit"]
      ])
  end

  it "has contact type groups content" do
    organization = build_stubbed(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    contact_type_group = build_stubbed(:contact_type_group, casa_org: organization, name: "Contact type group 1")
    assign(:contact_type_groups, [contact_type_group])

    render template: "casa_org/edit"

    expect(rendered).to have_text("Contact type group 1")
    expect(rendered).to have_text(contact_type_group.name)
    expect(rendered).to have_table("contact-type-groups",
      with_rows: [
        ["Contact type group 1", "Yes", "Edit"]
      ])
  end

  it "has hearing types content" do
    organization = build_stubbed(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    hearing_type = build_stubbed(:hearing_type, casa_org: organization, name: "Hearing type 1")
    assign(:hearing_types, [hearing_type])

    render template: "casa_org/edit"

    expect(rendered).to have_text("Hearing type 1")
    expect(rendered).to have_table("hearing-types",
      with_rows:
      [
        ["Hearing type 1", "Yes", "Edit"]
      ])
  end

  it "has judge content" do
    organization = build_stubbed(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)
    judge = build_stubbed(:judge, casa_org: organization, name: "Joey Tom")
    assign(:judges, [judge])

    render template: "casa_org/edit"

    expect(rendered).to have_text(judge.name)
  end

  it "does not show download prompt with no custom template" do
    organization = build_stubbed(:casa_org)
    allow(view).to receive(:current_organization).and_return(organization)

    render template: "casa_org/edit"

    expect(rendered).not_to have_text("Download Current Template")
  end

  it "has sent emails content" do
    organization = build_stubbed(:casa_org)
    admin = build_stubbed(:casa_admin, casa_org: organization)
    allow(view).to receive(:current_organization).and_return(organization)
    without_partial_double_verification do
      allow(view).to receive(:to_user_timezone).and_return(Time.zone.local(2021, 1, 2, 12, 30, 0))
    end

    sent_email = build_stubbed(:sent_email, user: admin, created_at: Time.zone.local(2021, 1, 2, 12, 30, 0))
    assign(:sent_emails, [sent_email])

    render template: "casa_org/edit"

    expect(rendered).to have_text(sent_email.sent_address)
    expect(rendered).to have_table("sent-emails",
      with_rows: [
        ["Mailer Type", "Mail Action Category", admin.email, "12:30pm 02 Jan 2021"]
      ])
  end

  context "with a template uploaded" do
    it "renders a prompt to download current template" do
      organization = create(:casa_org)
      allow(view).to receive(:current_organization).and_return(organization)

      organization.court_report_template.attach(io: File.open("#{Rails.root}/app/documents/templates/default_report_template.docx"), filename: 'default_report_template
.docx', content_type: "application/docx")

      render template: "casa_org/edit"

      expect(rendered).to have_text("Download Current Template")
    end
  end

  describe "additional expense feature flag" do
    context "enabled" do
      it "has option to enable additional expenses" do
        allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(true)
        organization = build_stubbed(:casa_org)
        allow(view).to receive(:current_organization).and_return(organization)

        render template: "casa_org/edit"

        expect(rendered).to have_text("Volunteers can add Other Expenses")
      end
    end

    context "disabled" do
      it "has option to enable additional expenses" do
        allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(false)
        organization = build_stubbed(:casa_org)
        allow(view).to receive(:current_organization).and_return(organization)

        render template: "casa_org/edit"

        expect(rendered).not_to have_text("Volunteers can add Other Expenses")
      end
    end
  end
end
