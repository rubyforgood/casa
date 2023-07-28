require "rails_helper"

RSpec.describe "casa_org/edit", type: :view do
  let(:organization) { create :casa_org }
  let(:admin) { build_stubbed(:all_casa_admin) }
  let(:contact_type_groups) { [] }
  let(:contact_types) { [] }

  before do
    allow(view).to receive(:current_organization).and_return(organization)
    assign(:contact_type_groups, [])
    assign(:contact_types, [])
    assign(:hearing_types, [])
    assign(:judges, [])
    assign(:sent_emails, [])



    sign_in admin

    render template: "casa_org/edit"
  end

  it "renders and does not show download prompt if new org" do
    expect(rendered).not_to have_text("Download Current Template")
  end

  context "with a template uploaded" do
    before do
      organization.court_report_template.attach(io: File.open("#{Rails.root}/app/documents/templates/default_report_template.docx"), filename: 'default_report_template
.docx', content_type: "application/docx")
    end

    it "renders a prompt to download current template" do
      expect(rendered).not_to have_text("Download Current Template")
    end
  end
end
