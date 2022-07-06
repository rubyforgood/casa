require "rails_helper"

RSpec.describe PatchNotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/patch_notes").to route_to("patch_notes#index")
    end

    it "routes to #new" do
      expect(get: "/patch_notes/new").to route_to("patch_notes#new")
    end

    it "routes to #show" do
      expect(get: "/patch_notes/1").to route_to("patch_notes#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/patch_notes/1/edit").to route_to("patch_notes#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/patch_notes").to route_to("patch_notes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/patch_notes/1").to route_to("patch_notes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/patch_notes/1").to route_to("patch_notes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/patch_notes/1").to route_to("patch_notes#destroy", id: "1")
    end
  end
end
