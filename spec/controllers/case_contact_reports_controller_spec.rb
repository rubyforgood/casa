require "rails_helper"

RSpec.describe CaseContactReportsController, type: :controller do
  let(:case_contact) { create(:case_contact) }
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:volunteer) { create(:volunteer) }

  before do
    travel_to Time.zone.local(2020, 1, 1)
  end

  after { travel_back }

  describe "GET index" do
    shared_examples "can view reports" do
      context "with start_date and end_date" do
        let(:case_contact_report_params) do
          {
            start_date: 1.month.ago,
            end_date: Date.today
          }
        end

        it "renders a csv file to download" do
          get :index, params: {format: :csv, report: {start_date: 1.month.ago, end_date: Date.today}}

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-1577836800.csv'
        end
      end

      context "without start_date and end_date" do
        it "renders a csv file to download" do
          get :index, params: {format: :csv, report: {start_date: "", end_date: ""}}

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

          get :index, params: {format: :csv, report: {creator_ids: [volunteer.id]}}

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-'
          expect(response.body).to match(/^#{contact.id},/)
          expect(response.body.lines.length).to eq(2)
        end
      end
    end

    context "when casa_admin" do
      it_behaves_like "can view reports" do
        let(:user) { admin }
      end

      before do
        sign_in admin
      end

      it "passes in casa_org_id to CaseContractReport" do
        allow(CaseContactReport).to receive(:new).and_return([])

        get :index, params: {format: :csv, report: {creator_ids: [admin.id]}}

        expect(CaseContactReport).to have_received(:new)
          .with(hash_including(casa_org_id: admin.casa_org_id))
      end
    end

    context "when supervisor" do
      before do
        sign_in supervisor
      end

      it_behaves_like "can view reports" do
        let(:user) { supervisor }
      end
    end

    context "when volunteer" do
      before do
        sign_in volunteer
      end

      it "cannot view reports" do
        get :index, params: {format: :csv, report: {}}
        expect(response).to redirect_to root_path
      end
    end
  end
end
