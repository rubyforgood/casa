require "rails_helper"

RSpec.describe AllCasaAdmins::PatchNotesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/all_casa_admins/patch_notes").to route_to("all_casa_admins/patch_notes#index")
    end

    it "routes to #create" do
      expect(post: "/all_casa_admins/patch_notes").to route_to("all_casa_admins/patch_notes#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/all_casa_admins/patch_notes/1").to route_to("all_casa_admins/patch_notes#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/all_casa_admins/patch_notes/1").to route_to("all_casa_admins/patch_notes#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/all_casa_admins/patch_notes/1").to route_to("all_casa_admins/patch_notes#destroy", id: "1")
    end
  end
end
