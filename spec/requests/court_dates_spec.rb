require "rails_helper"

RSpec.describe "/casa_cases/:casa_case_id/court_dates/:id", type: :request do
  let(:admin) { create(:casa_admin) }
  let(:casa_case) { court_date.casa_case }
  let(:court_date) { create(:court_date) }
  let(:hearing_type) { create(:hearing_type) }
  let(:judge) { create(:judge, name: "8`l/UR*|`=Iab'A") }
  let(:valid_attributes) do
    {
      date: Date.yesterday,
      hearing_type_id: hearing_type.id,
      judge_id: judge.id
    }
  end
  let(:texts) { ["1-New Order Text One", "0-New Order Text Two"] }
  let(:implementation_statuses) { ["unimplemented", nil] }
  let(:orders_attributes) do
    {
      "0" => {text: texts[0], implementation_status: implementation_statuses[0], casa_case_id: casa_case.id},
      "1" => {text: texts[1], implementation_status: implementation_statuses[1], casa_case_id: casa_case.id}
    }
  end
  let(:invalid_attributes) do
    {
      date: nil,
      hearing_type_id: hearing_type.id,
      judge_id: judge.id
    }
  end

  before do
    travel_to Date.new(2021, 1, 1)
    sign_in admin
  end

  describe "GET /show" do
    subject(:show) { get casa_case_court_date_path(casa_case, court_date) }

    before { show }

    context "when the request is authenticated" do
      it { expect(response).to have_http_status(:success) }
    end

    context "when the request is unauthenticated" do
      it "redirects to login page" do
        sign_out admin
        get casa_case_court_date_path(casa_case, court_date)
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when request format is word document" do
      subject(:show) { get casa_case_court_date_path(casa_case, court_date), headers: headers }

      let(:headers) { {accept: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"} }
      let(:formatted_court_date) { I18n.l(court_date.date, format: :full, default: nil) }

      it { expect(response).to be_successful }

      it "displays the court date" do
        show

        document_inspector = DocxInspector.new(docx_contents: response.body)

        expect(document_inspector.word_list_document_contains?(formatted_court_date)).to eq(true)
      end

      context "with a court order" do
        let!(:court_date) {
          create(:court_date, :with_court_order)
        }
        it "includes court order info" do
          show

          document_inspector = DocxInspector.new(docx_contents: response.body)

          expect(document_inspector.word_list_document_contains?("Ordered")).to eq(true) # Court Orders:
          expect(document_inspector.word_list_document_contains?(court_date.case_court_orders.first.text)).to eq(true)
          expect(document_inspector.word_list_document_contains?(court_date.case_court_orders.first.implementation_status.humanize)).to eq(true)
        end
      end

      context "without a court order" do
        let!(:court_date) {
          create(:court_date)
        }
        it "does not include court orders section" do
          show

          document_inspector = DocxInspector.new(docx_contents: response.body)

          expect(document_inspector.word_list_document_contains?("Court Orders:")).to eq(false) # Court Orders:
        end
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_casa_case_court_date_path(casa_case)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_casa_case_court_date_path(casa_case, court_date)
      expect(response).to be_successful
    end

    it "fails across organizations" do
      other_org = create(:casa_org)
      other_case = create(:casa_case, casa_org: other_org)

      get edit_casa_case_court_date_path(other_case, court_date)
      expect(response).to be_not_found
    end
  end

  describe "POST /create" do
    let(:casa_case) { create(:casa_case) }
    let(:court_date) { CourtDate.last }

    context "with valid parameters" do
      it "creates a new CourtDate" do
        expect do
          post casa_case_court_dates_path(casa_case), params: {court_date: valid_attributes}
        end.to change(CourtDate, :count).by(1)
      end

      it "sets the court_report_due_date to be 3 weeks before the court_date" do
        post casa_case_court_dates_path(casa_case), params: {court_date: valid_attributes}

        expect(court_date.casa_case.court_dates.last.court_report_due_date).to eq(valid_attributes[:date] - 3.weeks)
      end

      it "redirects to the casa_case" do
        post casa_case_court_dates_path(casa_case), params: {court_date: valid_attributes}
        expect(response).to redirect_to(casa_case_court_date_path(casa_case, court_date))
      end

      it "sets fields correctly" do
        post casa_case_court_dates_path(casa_case), params: {court_date: valid_attributes}

        expect(court_date.casa_case).to eq casa_case
        expect(court_date.date).to eq Date.yesterday
        expect(court_date.hearing_type).to eq hearing_type
        expect(court_date.judge).to eq judge
      end

      context "with case_court_orders_attributes being passed as a parameter" do
        let(:valid_params) do
          attributes = valid_attributes
          attributes[:case_court_orders_attributes] = orders_attributes
          attributes
        end

        it "Creates a new CaseCourtOrder" do
          expect do
            post casa_case_court_dates_path(casa_case), params: {court_date: valid_params}
          end.to change(CaseCourtOrder, :count).by(2)
        end

        it "sets fields correctly" do
          post casa_case_court_dates_path(casa_case), params: {court_date: valid_params}

          expect(court_date.case_court_orders.count).to eq 2
          expect(court_date.case_court_orders[0].text).to eq texts[0]
          expect(court_date.case_court_orders[0].implementation_status).to eq implementation_statuses[0]
          expect(court_date.case_court_orders[1].text).to eq texts[1]
          expect(court_date.case_court_orders[1].implementation_status).to eq implementation_statuses[1]
        end
      end
    end

    context "for a future court date" do
      let(:valid_attributes) do
        {
          date: 10.days.from_now,
          hearing_type_id: hearing_type.id,
          judge_id: judge.id
        }
      end

      it "creates a new CourtDate" do
        expect do
          post casa_case_court_dates_path(casa_case), params: {court_date: valid_attributes}
        end.to change(CourtDate, :count).by(1)
      end
    end

    describe "invalid request" do
      context "with invalid parameters" do
        it "does not create a new CourtDate" do
          expect do
            post casa_case_court_dates_path(casa_case), params: {court_date: invalid_attributes}
          end.to change(CourtDate, :count).by(0)
        end

        it "renders a successful response (i.e. to display the 'new' template)" do
          post casa_case_court_dates_path(casa_case), params: {court_date: invalid_attributes}
          expect(response).to be_successful
          expect(assigns[:court_date].errors.full_messages).to eq ["Date can't be blank"]
        end
      end
    end
  end

  describe "PATCH /update" do
    let(:new_attributes) {
      {
        date: 1.week.ago.to_date,
        hearing_type_id: hearing_type.id,
        judge_id: judge.id,
        case_court_orders_attributes: orders_attributes
      }
    }

    context "with valid parameters" do
      it "updates the requested court_date" do
        patch casa_case_court_date_path(casa_case, court_date), params: {court_date: new_attributes}
        court_date.reload
        expect(court_date.date).to eq 1.week.ago.to_date
        expect(court_date.hearing_type).to eq hearing_type
        expect(court_date.judge).to eq judge
        expect(court_date.case_court_orders[0].text).to eq texts[0]
        expect(court_date.case_court_orders[0].implementation_status).to eq implementation_statuses[0]
        expect(court_date.case_court_orders[1].text).to eq texts[1]
        expect(court_date.case_court_orders[1].implementation_status).to eq implementation_statuses[1]
      end

      it "redirects to the court_date" do
        patch casa_case_court_date_path(casa_case, court_date), params: {court_date: new_attributes}

        expect(response).to redirect_to casa_case_court_date_path(casa_case, court_date)
      end
    end

    context "with invalid parameters" do
      it "renders a successful response displaying the edit template" do
        patch casa_case_court_date_path(casa_case, court_date), params: {court_date: invalid_attributes}

        expect(response).to be_successful
        expect(assigns[:court_date].errors.full_messages).to eq ["Date can't be blank"]
      end
    end

    describe "court orders" do
      context "when the user tries to make an existing order empty" do
        let(:orders_updated) do
          {
            case_court_orders_attributes: {
              "0" => {
                text: "New Order Text One Updated",
                implementation_status: :unimplemented
              },
              "1" => {
                text: ""
              }
            }
          }
        end

        before do
          patch casa_case_court_date_path(casa_case, court_date), params: {court_date: new_attributes}
          court_date.reload

          @first_order_id = court_date.case_court_orders[0].id
          @second_order_id = court_date.case_court_orders[1].id

          orders_updated[:case_court_orders_attributes]["0"][:id] = @first_order_id
          orders_updated[:case_court_orders_attributes]["1"][:id] = @second_order_id
        end

        it "still updates the first order" do
          expect do
            patch casa_case_court_date_path(casa_case, court_date), params: {court_date: orders_updated}
          end.to(
            change { court_date.reload.case_court_orders.find(@first_order_id).text }
          )
        end

        it "does not update the second order" do
          expect do
            patch casa_case_court_date_path(casa_case, court_date), params: {court_date: orders_updated}
          end.not_to(
            change { court_date.reload.case_court_orders.find(@second_order_id).text }
          )
        end
      end
    end

    it "does not update across organizations" do
      other_org = create(:casa_org)
      other_casa_case = create(:casa_case, case_number: "abc", casa_org: other_org)

      expect do
        patch casa_case_court_date_path(other_casa_case, court_date), params: {court_date: new_attributes}
      end.not_to(
        change { court_date.reload.date }
      )
    end
  end

  describe "DELETE /destroy" do
    subject(:request) do
      delete casa_case_court_date_path(casa_case, court_date)

      response
    end

    shared_examples "successful deletion" do
      it "removes court date record" do
        court_date
        expect { request }.to change { CourtDate.count }.by(-1)
      end

      it { is_expected.to redirect_to(casa_case_path(casa_case)) }

      it "shows correct flash message" do
        request
        expect(flash[:notice]).to match(/Court date was successfully deleted./)
      end
    end

    shared_examples "unsuccessful deletion" do
      it "does not remove court date record" do
        court_date
        expect { request }.not_to change { CourtDate.count }
      end

      it { is_expected.to redirect_to(casa_case_court_date_path(casa_case, court_date)) }

      it "shows correct flash message" do
        request
        expect(flash[:notice]).to match(/You can delete only future court dates./)
      end
    end

    context "when the court date is in the past" do
      it_behaves_like "unsuccessful deletion"
    end

    context "when the court date is today" do
      let(:court_date) { create(:court_date, date: Date.current) }

      it_behaves_like "unsuccessful deletion"
    end

    context "when the court date is in the future" do
      let(:court_date) { create(:court_date, date: 1.day.from_now) }

      it_behaves_like "successful deletion"
    end
  end
end
