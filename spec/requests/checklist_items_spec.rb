require 'rails_helper'

RSpec.describe "ChecklistItems", type: :request do
  describe "GET new" do
    context "when logged in as an admin user" do
      it "the new checklist item page should load successfully" do
        sign_in_as_admin
        get new_hearing_type_checklist_item_path(create(:hearing_type))
        expect(response).to be_successful
      end
    end

    context "when logged in as a non-admin user" do
      it "does not allow access to the new checklist item page" do
        sign_in_as_volunteer
        get new_hearing_type_checklist_item_path(create(:hearing_type))
        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end
  end

  describe "POST create" do
    context "when logged in as an admin user" do
      it "should allow for the creation of checklist items" do
        sign_in_as_admin
        hearing_type = create(:hearing_type)
        post hearing_type_checklist_items_path(
          {
            hearing_type_id: hearing_type.id,
            checklist_item: {
              description: "checklist item description",
              category: "checklist item category",
              mandatory: false
            }
          }
        )
        expect(response).to redirect_to edit_hearing_type_path(hearing_type)
        expect(ChecklistItem.count).to eq 1
      end
    end

    context "when logged in as a non-admin user" do
      it "should not allow for the creation of checklist items" do
        sign_in_as_volunteer
        hearing_type = create(:hearing_type)
        post hearing_type_checklist_items_path(
          {
            hearing_type_id: hearing_type.id,
            checklist_item: {
              description: "checklist item description",
              category: "checklist item category",
              mandatory: false
            }
          }
        )
        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end
  end
end
