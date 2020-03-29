require "rails_helper"

RSpec.describe CasesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/cases").to route_to("cases#index")
    end

    it "routes to #new" do
      expect(get: "/cases/new").to route_to("cases#new")
    end

    it "routes to #show" do
      expect(get: "/cases/1").to route_to("cases#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/cases/1/edit").to route_to("cases#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/cases").to route_to("cases#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/cases/1").to route_to("cases#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/cases/1").to route_to("cases#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/cases/1").to route_to("cases#destroy", id: "1")
    end
  end
end
