require "rails_helper"

RSpec.describe "/additional_expenses", type: :request do
  let(:casa_org) { create :casa_org }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create :case_contact, casa_case:, creator: volunteer }

  let(:valid_attributes) do
    attributes_for(:additional_expense)
      .merge({case_contact_id: case_contact.id})
  end
  let(:invalid_attributes) { valid_attributes.merge({other_expenses_describe: nil, other_expense_amount: 1}) }

  before { sign_in volunteer }

  describe "POST /create" do
    let(:params) { {additional_expense: valid_attributes} }

    subject { post additional_expenses_path, params:, as: :json }

    it "creates a record and responds created" do
      expect { subject }.to change(AdditionalExpense, :count).by(1)
      expect(response).to have_http_status(:created)
    end

    it "returns the new contact topic answer as json" do
      subject
      expect(response.content_type).to match(a_string_including("application/json"))
      answer = AdditionalExpense.last
      expect(response_json[:id]).to eq answer.id
      expect(response_json.keys)
        .to include(:id, :case_contact_id, :other_expense_amount, :other_expenses_describe)
    end

    context "with invalid parameters" do
      let(:params) { {additional_expense: invalid_attributes} }

      it "fails and responds unprocessable_entity" do
        expect { subject }.to change(ContactTopicAnswer, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns errors as json" do
        subject
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response.body).to be_present
        expect(response_json[:other_expenses_describe]).to include("can't be blank")
      end
    end

    context "html request" do
      subject { post additional_expenses_path, params: }

      it "redirects to referrer/root without creating an additional expense" do
        expect { subject }.to not_change(AdditionalExpense, :count)
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:additional_expense) { create :additional_expense, case_contact: }

    subject { delete additional_expense_url(additional_expense), as: :json }

    it "destroys the record and responds no content" do
      expect { subject }
        .to change(AdditionalExpense, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end

    context "html request" do
      subject { delete additional_expense_url(additional_expense) }

      it "redirects to referrer/root without destroying the additional expense" do
        expect { subject }.to not_change(AdditionalExpense, :count)
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
