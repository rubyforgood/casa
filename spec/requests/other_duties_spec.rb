require "rails_helper"

RSpec.describe "/other_duties", type: :request do
  context "logged in as volunteer" do
    before { sign_in_as_volunteer }

    describe "POST /create" do
      context "with valid parameters" do
        let(:valid_attributes) do
          attributes_for(:other_duty)
        end

        it "does create one new Duty" do
          expect {
            post other_duties_path, params: {other_duty: valid_attributes}
          }.to change(OtherDuty, :count).by(1)
        end

        it "returns page casa_cases_path" do
          post other_duties_path, params: {other_duty: valid_attributes}
          expect(response).to redirect_to(casa_cases_path)
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) do
          attributes_for(:other_duty, notes: "")
        end

        it "does not create a new Duty" do
          expect {
            post other_duties_path, params: {other_duty: invalid_attributes}
          }.to change(OtherDuty, :count).by(0)
        end

        it "renders a successful response" do
          post other_duties_path, params: {other_duty: invalid_attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        it "updates the duty" do
          other_duty = create(:other_duty, notes: "Test 1")
          other_duty.notes = "Test 2"

          patch other_duty_path(other_duty), params: {id: other_duty.id, other_duty: other_duty.attributes}
          other_duty.reload

          expect(other_duty.notes).to eq("Test 2")
        end

        it "returns page casa_cases_path" do
          other_duty = create(:other_duty, notes: "Test 1")
          other_duty.notes = "Test 2"

          patch other_duty_path(other_duty), params: {id: other_duty.id, other_duty: other_duty.attributes}
          other_duty.reload

          expect(response).to redirect_to(casa_cases_path)
        end
      end

      context "with invalid parameters" do
        it "renders an error response" do
          other_duty = create(:other_duty, notes: "Test 1")
          other_duty.notes = ""

          patch other_duty_path(other_duty), params: {id: other_duty.id, other_duty: other_duty.attributes}
          other_duty.reload

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
