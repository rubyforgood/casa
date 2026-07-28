# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LearningHourTypes", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { build(:casa_admin, casa_org:) }

  before do
    sign_in admin
  end

  describe "GET /new" do
    it "returns a successful response" do
      get new_learning_hour_type_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns a successful response" do
      learning_hour_type = create(:learning_hour_type, casa_org:)

      get edit_learning_hour_type_path(learning_hour_type)

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "when the params are valid" do
      it "creates the learning hour type successfully and redirects to the organization's edit page" do
        params = {
          learning_hour_type: {
            name: "Homeschooling",
            active: true
          }
        }

        expect do
          post learning_hour_types_path, params: params
        end.to change(LearningHourType, :count).by(1)

        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to match(/learning type was successfully created/i)
        expect(response).to redirect_to(edit_casa_org_path(casa_org))
      end
    end

    context "when the params are not valid" do
      it "returns an unprocessable_content response" do
        params = {
          learning_hour_type: {
            active: true
          }
        }

        expect do
          post learning_hour_types_path, params: params
        end.not_to change(LearningHourType, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "when the params are valid" do
      it "updates the learning hour type successfully and redirects to the organization's edit page" do
        learning_hour_type = create(:learning_hour_type, casa_org:, name: "Homeschooling")

        params = {learning_hour_type: {name: "Remote"}}
        patch learning_hour_type_path(learning_hour_type), params: params

        expect(response).to redirect_to(edit_casa_org_path(casa_org))
        expect(learning_hour_type.reload.name).to eq("Remote")
        expect(flash[:notice]).to match(/learning type was successfully updated/i)
      end
    end

    context "when the params are invalid" do
      it "returns an unprocessable_content response" do
        learning_hour_type = create(:learning_hour_type, casa_org:, name: "Homeschooling")

        params = {learning_hour_type: {name: nil}}
        patch learning_hour_type_path(learning_hour_type), params: params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
