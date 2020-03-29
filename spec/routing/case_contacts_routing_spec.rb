require "rails_helper"

RSpec.describe CaseContactsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/case_contacts").to route_to("case_contacts#index")
    end

    it "routes to #new" do
      expect(get: "/case_contacts/new").to route_to("case_contacts#new")
    end

    it "routes to #show" do
      expect(get: "/case_contacts/1").to route_to("case_contacts#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/case_contacts/1/edit").to route_to("case_contacts#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/case_contacts").to route_to("case_contacts#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/case_contacts/1").to route_to("case_contacts#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/case_contacts/1").to route_to("case_contacts#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/case_contacts/1").to route_to("case_contacts#destroy", id: "1")
    end
  end
end
