require "rails_helper"

RSpec.describe "BulkCourtDates", type: :request do
  let(:user) { create(:supervisor) }

  before { sign_in user }

  describe "GET /new" do
    subject { get "/bulk_court_dates/new" }

    it "renders the new template" do
      subject
      expect(response).to have_http_status :success
      expect(response).to render_template :new
    end
  end

  describe "POST /create" do
    let(:judge) { create :judge }
    let(:hearing_type) { create :hearing_type }
    let(:case_count) { 2 }
    let(:case_group) { create :case_group, case_count:, casa_org: user.casa_org }
    let(:court_date) { Date.tomorrow }
    let(:case_court_orders_attributes) { {} }
    let(:params) do
      {
        court_date: {
          case_group_id: case_group.id,
          date: Date.tomorrow,
          court_report_due_date: Date.today,
          judge_id: judge.id,
          hearing_type_id: hearing_type.id,
          case_court_orders_attributes:
        }
      }
    end

    subject { post "/bulk_court_dates", params: }

    it "renders the new template on success" do
      subject
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_bulk_court_date_path)
    end

    it "adds the court date to each group case" do
      expect(case_group.casa_cases.count).to be > 1
      cc_one = case_group.casa_cases.first
      cc_two = case_group.casa_cases.last

      expect { subject }
        .to change { cc_one.court_dates.count }.by(1)
        .and change { cc_two.court_dates.count }.by(1)
    end

    context "when different casa org's case group" do
      let(:case_group) { create :case_group, case_count:, casa_org: build(:casa_org) }

      it "raises ActiveRecord::RecordNotFound" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when court orders are in params" do
      let(:case_court_orders_attributes) do
        {
          "0" => {
            text: "Some court order",
            implementation_status: "partially_implemented"
          },
          "1" => {
            text: "Another court order",
            implementation_status: "implemented"
          }
        }
      end

      it "adds the court orders to each group case" do
        expect(case_group.casa_cases.count).to be > 1
        cc_one = case_group.casa_cases.first
        cc_two = case_group.casa_cases.last

        expect { subject }
          .to change { cc_one.case_court_orders.count }.by(case_court_orders_attributes.size)
          .and change { cc_two.case_court_orders.count }.by(case_court_orders_attributes.size)
      end
    end
  end
end
