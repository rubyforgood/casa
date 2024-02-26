require "rails_helper"

RSpec.describe "/contact_topics", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # ContactTopic. As you add validations to ContactTopic, be sure to
  # adjust the attributes here as well.
  let(:casa_org) { create(:casa_org) }
  let(:is_active) { nil }
  let(:contact_topic) { create(:contact_topic, casa_org:) }
  let(:attributes) { {casa_org_id: casa_org.id} }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }

  before { sign_in admin }

  describe "GET /new" do
    it "renders a successful response" do
      get new_contact_topic_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      get edit_contact_topic_url(contact_topic)
      expect(response).to be_successful
      expect(response.body).to include(contact_topic.question)
      expect(response.body).to include(contact_topic.details)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:attributes) do
        {
          casa_org_id: casa_org.id,
          question: "test question",
          details: "test details"
        }
      end

      it "creates a new ContactTopic" do
        expect do
          post contact_topics_url, params: {contact_topic: attributes}
        end.to change(ContactTopic, :count).by(1)

        topic = ContactTopic.last

        expect(topic.question).to eq("test question")
        expect(topic.details).to eq("test details")
      end

      it "redirects to the edit casa_org" do
        post contact_topics_url, params: {contact_topic: attributes}
        expect(response).to redirect_to(edit_casa_org_path(casa_org))
      end
    end

    context "with invalid parameters" do
      let(:attributes) { {casa_org_id: 0} }

      it "does not create a new ContactTopic" do
        expect do
          post contact_topics_url, params: {contact_topic: attributes}
        end.to change(ContactTopic, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post contact_topics_url, params: {contact_topic: attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let!(:contact_topic) { create(:contact_topic, casa_org:) }

      let(:new_attributes) do
        {
          casa_org_id: casa_org.id,
          active: false,
          question: "test question",
          details: "test details"
        }
      end

      it "updates only values of the requested contact_topic" do
        patch contact_topic_url(contact_topic), params: {contact_topic: new_attributes}
        contact_topic.reload

        expect(contact_topic.active).to eq(true)
        expect(contact_topic.details).to eq("test details")
        expect(contact_topic.question).to eq("test question")
      end

      it "redirects to the casa_org edit" do
        patch contact_topic_url(contact_topic), params: {contact_topic: new_attributes}
        expect(response).to redirect_to(edit_casa_org_path(casa_org))
      end
    end

    context "with invalid parameters" do
      let(:attributes) { {casa_org_id: 0} }

      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        patch contact_topic_url(contact_topic), params: {contact_topic: attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:contact_topic) { create(:contact_topic, casa_org: casa_org) }
    it "does not destroy the requested contact_topic" do
      expect do
        delete contact_topic_url(contact_topic)
      end.to_not change(ContactTopic, :count)
    end

    it "set the requested contact_topic to inactive" do
      delete contact_topic_url(contact_topic)
      contact_topic.reload
      expect(contact_topic.active).to be false
    end

    it "redirects to edit casa_org" do
      delete contact_topic_url(contact_topic)
      expect(response).to redirect_to(edit_casa_org_path(casa_org))
    end
  end
end
