# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LearningHourTopics", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { build(:casa_admin, casa_org:) }

  before do
    sign_in admin
  end

  describe "GET /new" do
    it "returns a successful response" do
      get new_learning_hour_topic_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns a successful response" do
      learning_hour_topic = create(:learning_hour_topic, casa_org:)

      get edit_learning_hour_topic_path(learning_hour_topic)

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    context "when the params are valid" do
      it "creates the learning hour topic successfully and redirects to the organization's edit page" do
        params = {
          learning_hour_topic: {
            name: "Social Science"
          }
        }

        expect do
          post learning_hour_topics_path, params: params
        end.to change(LearningHourTopic, :count).by(1)

        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to match(/learning topic was successfully created/i)
        expect(response).to redirect_to(edit_casa_org_path(casa_org))
      end
    end

    context "when the params are not valid" do
      it "returns an unprocessable_content response" do
        params = {
          learning_hour_topic: {
            name: nil
          }
        }

        expect do
          post learning_hour_topics_path, params: params
        end.not_to change(LearningHourTopic, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "when the params are valid" do
      it "updates the learning hour type successfully and redirects to the organization's edit page" do
        learning_hour_topic = create(:learning_hour_topic, casa_org:, name: "Homeschooling")

        params = {learning_hour_topic: {name: "Remote"}}
        patch learning_hour_topic_path(learning_hour_topic), params: params

        expect(response).to redirect_to(edit_casa_org_path(casa_org))
        expect(learning_hour_topic.reload.name).to eq("Remote")
        expect(flash[:notice]).to match(/learning topic was successfully updated/i)
      end
    end

    context "when the params are invalid" do
      it "returns an unprocessable_content response" do
        learning_hour_topic = create(:learning_hour_topic, casa_org:, name: "Homeschooling")

        params = {learning_hour_topic: {name: nil}}
        patch learning_hour_topic_path(learning_hour_topic), params: params

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
