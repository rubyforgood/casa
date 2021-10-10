require "rails_helper"

RSpec.describe "/casa_cases/:casa_case_id/past_court_dates/:id", type: :request do
  let(:admin) { create(:casa_admin) }
  let(:casa_case) { past_court_date.casa_case }
  let(:past_court_date) { create(:past_court_date) }
  let(:hearing_type) { create(:hearing_type) }
  let(:judge) { create(:judge) }
  let(:valid_attributes) do
    {
      date: Date.yesterday,
      hearing_type_id: hearing_type.id,
      judge_id: judge.id
    }
  end
  let(:mandate_texts) { ["1-New Mandate Text One", "0-New Mandate Text Two"] }
  let(:implementation_statuses) { ["not_implemented", nil] }
  let(:mandates_attributes) do
    {
      "0" => {mandate_text: mandate_texts[0], implementation_status: implementation_statuses[0], casa_case_id: casa_case.id},
      "1" => {mandate_text: mandate_texts[1], implementation_status: implementation_statuses[1], casa_case_id: casa_case.id}
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
    subject(:show) { get casa_case_past_court_date_path(casa_case, past_court_date) }

    before { show }

    context "when the request is authenticated" do
      it { expect(response).to have_http_status(:success) }
    end

    context "when the request is unauthenticated" do
      it "redirects to login page" do
        sign_out admin
        get casa_case_past_court_date_path(casa_case, past_court_date)
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when request format is word document" do
      subject(:show) { get casa_case_past_court_date_path(casa_case, past_court_date), headers: headers }

      let(:headers) { {accept: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"} }

      it { expect(response).to be_successful }

      it "displays the court date" do
        show
        document = get_docx_contents_as_string(response.body, collapse: true)
        expect(document).to include(past_court_date.date.to_s)
      end

      context "when a judge is attached" do
        let!(:past_court_date) {
          create(:past_court_date, date: Date.yesterday, judge: judge)
        }
        it "includes the judge's name in the document" do
          show
          document = get_docx_contents_as_string(response.body, collapse: true)
          expect(document).to include(judge.name)
        end
      end

      context "without a judge" do
        let!(:past_court_date) {
          create(:past_court_date, date: Date.yesterday, judge: nil)
        }
        it "includes None for the judge's name in the document" do
          show
          document = get_docx_contents_as_string(response.body, collapse: true)
          expect(document).not_to include(judge.name)
          expect(document.downcase).to include("judge: none")
        end
      end

      context "with a hearing type" do
        let!(:past_court_date) {
          create(:past_court_date, date: Date.yesterday, hearing_type: hearing_type)
        }
        it "includes the hearing type in the document" do
          show
          document = get_docx_contents_as_string(response.body, collapse: true)
          expect(document).to include(hearing_type.name)
        end
      end

      context "without a hearing type" do
        let!(:past_court_date) {
          create(:past_court_date, date: Date.yesterday, hearing_type: nil)
        }
        it "includes None for the hearing type in the document" do
          show
          document = get_docx_contents_as_string(response.body, collapse: true)
          expect(document).not_to include(hearing_type.name)
          expect(document.downcase).to include("hearing type: none")
        end
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_casa_case_past_court_date_path(casa_case)
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_casa_case_past_court_date_path(casa_case, past_court_date)
      expect(response).to be_successful
    end

    it "fails across organizations" do
      other_org = create(:casa_org)
      other_case = create(:casa_case, casa_org: other_org)

      get edit_casa_case_past_court_date_path(other_case, past_court_date)
      expect(response).to be_not_found
    end
  end

  describe "POST /create" do
    let(:casa_case) { create(:casa_case) }
    let(:past_court_date) { PastCourtDate.last }

    context "with valid parameters" do
      it "creates a new PastCourtDate" do
        expect do
          post casa_case_past_court_dates_path(casa_case), params: {past_court_date: valid_attributes}
        end.to change(PastCourtDate, :count).by(1)
      end

      it "redirects to the casa_case" do
        post casa_case_past_court_dates_path(casa_case), params: {past_court_date: valid_attributes}
        expect(response).to redirect_to(casa_case_past_court_date_path(casa_case, past_court_date))
      end

      it "sets fields correctly" do
        post casa_case_past_court_dates_path(casa_case), params: {past_court_date: valid_attributes}

        expect(past_court_date.casa_case).to eq casa_case
        expect(past_court_date.date).to eq Date.yesterday
        expect(past_court_date.hearing_type).to eq hearing_type
        expect(past_court_date.judge).to eq judge
      end

      context "with case_court_mandates_attributes being passed as a parameter" do
        let(:valid_params) do
          attributes = valid_attributes
          attributes[:case_court_mandates_attributes] = mandates_attributes
          attributes
        end

        it "Creates a new CaseCourtMandate" do
          expect do
            post casa_case_past_court_dates_path(casa_case), params: {past_court_date: valid_params}
          end.to change(CaseCourtMandate, :count).by(2)
        end

        it "sets fields correctly" do
          post casa_case_past_court_dates_path(casa_case), params: {past_court_date: valid_params}

          expect(past_court_date.case_court_mandates.count).to eq 2
          expect(past_court_date.case_court_mandates[0].mandate_text).to eq mandate_texts[0]
          expect(past_court_date.case_court_mandates[0].implementation_status).to eq implementation_statuses[0]
          expect(past_court_date.case_court_mandates[1].mandate_text).to eq mandate_texts[1]
          expect(past_court_date.case_court_mandates[1].implementation_status).to eq implementation_statuses[1]
        end
      end
    end

    describe "invalid request" do
      context "with invalid parameters" do
        it "does not create a new PastCourtDate" do
          expect do
            post casa_case_past_court_dates_path(casa_case), params: {past_court_date: invalid_attributes}
          end.to change(PastCourtDate, :count).by(0)
        end

        it "renders a successful response (i.e. to display the 'new' template)" do
          post casa_case_past_court_dates_path(casa_case), params: {past_court_date: invalid_attributes}
          expect(response).to be_successful
          expect(assigns[:past_court_date].errors.full_messages).to eq ["Date can't be blank"]
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
        case_court_mandates_attributes: mandates_attributes
      }
    }

    context "with valid parameters" do
      it "updates the requested past_court_date" do
        patch casa_case_past_court_date_path(casa_case, past_court_date), params: {past_court_date: new_attributes}
        past_court_date.reload
        expect(past_court_date.date).to eq 1.week.ago.to_date
        expect(past_court_date.hearing_type).to eq hearing_type
        expect(past_court_date.judge).to eq judge
        expect(past_court_date.case_court_mandates[0].mandate_text).to eq mandate_texts[0]
        expect(past_court_date.case_court_mandates[0].implementation_status).to eq implementation_statuses[0]
        expect(past_court_date.case_court_mandates[1].mandate_text).to eq mandate_texts[1]
        expect(past_court_date.case_court_mandates[1].implementation_status).to eq implementation_statuses[1]
      end

      it "redirects to the past_court_date" do
        patch casa_case_past_court_date_path(casa_case, past_court_date), params: {past_court_date: new_attributes}

        expect(response).to redirect_to casa_case_past_court_date_path(casa_case, past_court_date)
      end
    end

    context "with invalid parameters" do
      it "renders a successful response displaying the edit template" do
        patch casa_case_past_court_date_path(casa_case, past_court_date), params: {past_court_date: invalid_attributes}

        expect(response).to be_successful
        expect(assigns[:past_court_date].errors.full_messages).to eq ["Date can't be blank"]
      end
    end

    describe "court mandates" do
      context "when the user tries to make an existing mandate empty" do
        let(:mandates_updated) do
          {
            case_court_mandates_attributes: {
              "0" => {
                mandate_text: "New Mandate Text One Updated",
                implementation_status: :not_implemented
              },
              "1" => {
                mandate_text: ""
              }
            }
          }
        end

        before do
          patch casa_case_past_court_date_path(casa_case, past_court_date), params: {past_court_date: new_attributes}
          past_court_date.reload

          mandates_updated[:case_court_mandates_attributes]["0"][:id] = past_court_date.case_court_mandates[0].id
          mandates_updated[:case_court_mandates_attributes]["1"][:id] = past_court_date.case_court_mandates[1].id
        end

        it "does not update the first mandate" do
          expect do
            patch casa_case_past_court_date_path(casa_case, past_court_date), params: {past_court_date: mandates_updated}
          end.not_to(
            change { past_court_date.reload.case_court_mandates[0].mandate_text }
          )
        end

        it "does not update the second mandate" do
          expect do
            patch casa_case_past_court_date_path(casa_case, past_court_date), params: {past_court_date: mandates_updated}
          end.not_to(
            change { past_court_date.reload.case_court_mandates[1].mandate_text }
          )
        end
      end
    end

    it "does not update across organizations" do
      other_org = create(:casa_org)
      other_casa_case = create(:casa_case, case_number: "abc", casa_org: other_org)

      expect do
        patch casa_case_past_court_date_path(other_casa_case, past_court_date), params: {past_court_date: new_attributes}
      end.not_to(
        change { past_court_date.reload.date }
      )
    end
  end
end
