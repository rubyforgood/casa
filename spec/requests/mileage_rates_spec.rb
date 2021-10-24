require "rails_helper"

RSpec.describe "/mileage_rates", type: :request do
  let(:admin) { create(:casa_admin) }

  describe "GET /index" do
    it "renders a successful response" do
      sign_in admin

      get mileage_rates_path
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response only for admin user" do
      sign_in admin

      get new_mileage_rate_path
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    let(:mileage_rate) { MileageRate.last }
    before do
      sign_in admin
    end

    context "with valid params" do
      let(:params) do
        {
          mileage_rate: {
            user_id: admin.id,
            effective_date: DateTime.current,
            amount: "22.87"
          }
        }
      end

      it "creates a new mileage rate" do
        expect { post mileage_rates_path, params: params }.to change(MileageRate, :count).by(1)
        expect(response).to have_http_status(:redirect)
        expect(mileage_rate[:user_id]).to eq(admin.id)
        expect(mileage_rate[:effective_date]).to eq(params[:mileage_rate][:effective_date].to_date)
        expect(mileage_rate[:amount]).to eq(params[:mileage_rate][:amount].to_f)
        expect(response).to redirect_to mileage_rates_path
      end
    end

    context "with invalid parameters" do
      let(:params) do
        {
          mileage_rate: {
            user_id: admin.id,
            effective_date: DateTime.current,
            amount: ""
          }
        }
      end

      it "does not create a mileage rate" do
        expect {
          post mileage_rates_path, params: params
        }.to_not change { MileageRate.count }
        expect(response).to have_http_status(:success)
      end
    end

    context "when a previous mileage rate exists for the effective date" do
      let(:date) { DateTime.current }
      let(:params) do
        {
          mileage_rate: {
            user_id: admin.id,
            effective_date: date,
            amount: ""
          }
        }
      end

      before do
        create(:mileage_rate, effective_date: date)
      end

      it "must not create a new mileage rate" do
        expect {
          post mileage_rates_path, params: params
        }.to_not change { MileageRate.count }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /update" do
    let(:mileage_rate) { create(:mileage_rate, amount: 10.11, effective_date: DateTime.parse("01-01-2021")) }

    before { sign_in admin }

    context "with valid params" do
      it "updates the mileage_rate" do
        patch mileage_rate_path(mileage_rate), params: {
          mileage_rate: {
            amount: "22.87"
          }
        }
        expect(response).to have_http_status(:redirect)

        mileage_rate.reload
        expect(mileage_rate.amount).to eq 22.87
      end
    end

    context "with invalid parameters" do
      let(:params) do
        {
          mileage_rate: {
            amount: ""
          }
        }
      end

      it "does not update a mileage rate" do
        patch mileage_rate_path(mileage_rate), params: params

        expect(response).to have_http_status(:success)

        mileage_rate.reload
        expect(mileage_rate.amount).to eq(10.11)
      end
    end

    context "when updating the mileage rate effective date and already exists one" do
      let(:another_mileage_rate) { create(:mileage_rate) }
      let(:params) do
        {
          mileage_rate: {
            effective_date: DateTime.parse("01-01-2021")
          }
        }
      end

      it "does not update a mileage rate" do
        expect { patch mileage_rate_path(another_mileage_rate), params: params }.not_to change { another_mileage_rate }
      end
    end
  end
end
