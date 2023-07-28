require "rails_helper"

RSpec.describe "casa_org/edit", type: :view do
  before do
    assign(:contact_type_groups, [])
    assign(:contact_types, [])
    assign(:hearing_types, [])
    assign(:judges, [])
    assign(:sent_emails, [])

    sign_in build_stubbed(:all_casa_admin)
  end

  it "renders and does not show download prompt if new org" do
    organization = create :casa_org
    allow(view).to receive(:current_organization).and_return(organization)

    render template: "casa_org/edit"

    expect(rendered).not_to have_text("Download Current Template")
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
