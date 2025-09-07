require "rails_helper"

RSpec.describe "/case_contacts_new_design", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }

  before { sign_in admin }

  describe "GET /index" do
    subject(:request) do
      get case_contacts_new_design_path

      response
    end

    let!(:casa_case) { create(:casa_case, casa_org: organization) }
    let!(:past_contact) { create(:case_contact, :active, casa_case: casa_case, occurred_at: 3.weeks.ago) }
    let!(:recent_contact) { create(:case_contact, :active, casa_case: casa_case, occurred_at: 3.days.ago) }
    let!(:draft_contact) { create(:case_contact, casa_case: casa_case, occurred_at: 5.days.ago, status: "started") }

    it { is_expected.to have_http_status(:success) }

    it "lists exactly two active contacts and one draft" do
      doc = Nokogiri::HTML(request.body)
      case_contact_rows = doc.css('[data-testid="case_contact-row"]')
      expect(case_contact_rows.size).to eq(3)
    end

    it "shows the draft badge exactly once" do
      doc = Nokogiri::HTML(request.body)
      expect(doc.css('[data-testid="draft-badge"]').count).to eq(1)
    end

    it "orders contacts by occurred_at desc" do
      body = request.body

      recent_index = body.index(I18n.l(recent_contact.occurred_at, format: :full))
      past_index   = body.index(I18n.l(past_contact.occurred_at, format: :full))

      expect(recent_index).to be < past_index
    end
  end
end
