require "rails_helper"

RSpec.describe "LearningHourTopics", type: :request do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }

  describe "GET /new" do
    context "as an admin" do
      before { sign_in admin }

      it "renders successfully" do
        get new_learning_hour_topic_path
        expect(response).to have_http_status(:success)
      end
    end

    context "as a volunteer" do
      before { sign_in volunteer }

      it "redirects to root as not authorized" do
        get new_learning_hour_topic_path

        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end

  describe "POST /create" do
    before { sign_in admin }

    context "with valid params" do
      let(:params) { {learning_hour_topic: {name: "New Topic"}} }

      it "creates a learning hour topic and redirects" do
        expect {
          post learning_hour_topics_path, params: params
        }.to change(LearningHourTopic, :count).by(1)

        expect(response).to redirect_to(edit_casa_org_path(organization))
        follow_redirect!
        expect(response.body).to include("Learning Topic was successfully created.")
      end
    end

    context "with invalid params" do
      let(:params) { {learning_hour_topic: {name: ""}} }

      it "does not create a topic and renders new" do
        expect {
          post learning_hour_topics_path, params: params
        }.not_to change(LearningHourTopic, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /edit" do
    let(:topic) { create(:learning_hour_topic, casa_org: organization) }

    context "as an admin" do
      before { sign_in admin }

      it "renders successfully" do
        get edit_learning_hour_topic_path(topic)
        expect(response).to have_http_status(:success)
      end
    end

    context "as a volunteer" do
      before { sign_in volunteer }

      it "redirects to root as not authorized" do
        get edit_learning_hour_topic_path(topic)

        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "PATCH /update" do
    let(:topic) { create(:learning_hour_topic, casa_org: organization, name: "Old Name") }

    before { sign_in admin }

    context "with valid params" do
      it "updates the topic and redirects" do
        patch learning_hour_topic_path(topic), params: {learning_hour_topic: {name: "Updated Name"}}

        expect(response).to redirect_to(edit_casa_org_path(organization))
        expect(topic.reload.name).to eq("Updated Name")
      end
    end

    context "with invalid params" do
      it "does not update and renders edit" do
        patch learning_hour_topic_path(topic), params: {learning_hour_topic: {name: ""}}

        expect(response).to have_http_status(:unprocessable_content)
        expect(topic.reload.name).to eq("Old Name")
      end
    end
  end
end
