require "rails_helper"

RSpec.describe "/case_contact_reports", type: :request do
  let!(:case_contact) { build(:case_contact) }

  before do
    travel_to Time.zone.local(2020, 1, 1)
    sign_in user
  end

  after { travel_back }

  describe "GET /case_contact_reports" do
    context "as volunteer" do
      let(:user) { build(:volunteer) }

      it "cannot view reports" do
        get case_contact_reports_url(format: :csv), params: {report: {}}
        expect(response).to redirect_to root_path
      end
    end

    shared_examples "can view reports" do
      context "with start_date and end_date" do
        let(:case_contact_report_params) do
          {
            start_date: 1.month.ago,
            end_date: Date.today
          }
        end

        it "renders a csv file to download" do
          get case_contact_reports_url(format: :csv), params: {report: {start_date: 1.month.ago, end_date: Date.today}}

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-1577836800.csv'
        end
      end

      context "without start_date and end_date" do
        it "renders a csv file to download" do
          get case_contact_reports_url(format: :csv), params: {report: {start_date: "", end_date: ""}}

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-1577836800.csv'
        end
      end

      context "with supervisor_ids filter" do
        it "renders csv with only the volunteer" do
          volunteer = create(:volunteer)
          casa_case = build(:casa_case, casa_org: volunteer.casa_org)
          contact = create(:case_contact, creator_id: volunteer.id, casa_case: casa_case)
          build_stubbed(:case_contact, creator_id: user.id, casa_case: casa_case)

          get case_contact_reports_url(format: :csv), params: {report: {creator_ids: [volunteer.id]}}

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-'
          expect(response.body).to match(/^#{contact.id},/)
          expect(response.body.lines.length).to eq(2)
        end
      end

      context "casa_case_ids filter" do
        let!(:casa_case) { create(:casa_case) }
        let!(:case_contacts) { create_list(:case_contact, 3, casa_case: casa_case) }

        before { create_list(:case_contact, 5) }

        it "returns success with proper headers" do
          get case_contact_reports_url(format: :csv),
            params: { report: { casa_case_ids: [casa_case.id] } }

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-'
        end

        context "when filter is provided" do
          it "renders csv with contacts from the casa cases" do
            get case_contact_reports_url(format: :csv),
              params: { report: { casa_case_ids: [casa_case.id] } }

            expect(response.body.lines.length).to eq(4)

            case_contacts.each do |contact|
              expect(response.body).to match(/^#{contact.id}/)
            end
          end
        end

        context "when filter not provided" do
          it "renders a csv with all case contacts" do
            get case_contact_reports_url(format: :csv),
              params: { report: { casa_case_ids: nil } }

            expect(response.body.lines.length).to eq(9)

            CaseContact.all.pluck(:id).each do |id|
              expect(response.body).to match(/^#{id}/)
            end
          end
        end
      end
    end

    context "as supervisor" do
      it_behaves_like "can view reports" do
        let(:user) { build(:supervisor) }
      end
    end

    context "as casa_admin" do
      it_behaves_like "can view reports" do
        let(:user) { build(:casa_admin) }
      end

      let(:user) { build(:casa_admin) }
      it "passes in casa_org_id to CaseContractReport" do
        allow(CaseContactReport).to receive(:new).and_return([])

        get case_contact_reports_url(format: :csv), params: {report: {creator_ids: [user.id]}}

        expect(CaseContactReport).to have_received(:new)
          .with(hash_including(casa_org_id: user.casa_org_id))
      end
    end
  end

  def case_contact_report_params
    {
      start_date: 1.month.ago,
      end_date: Date.today
    }
  end
end
