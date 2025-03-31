require "rails_helper"

RSpec.describe CaseContactsController, type: :controller do
  describe "GET #index" do
    # Create test data in before block to keep tests DRY
    before do
      sign_in user
      
      @casa_case1 = create(:casa_case)
      @casa_case2 = create(:casa_case)
      
      @contact1 = create(:case_contact, casa_case: @casa_case1)
      @contact2 = create(:case_contact, casa_case: @casa_case1)
      @contact3 = create(:case_contact, casa_case: @casa_case2)
    end
    
    context "when casa_case_id param is present" do
      it "filters case contacts for the specified casa case" do
        get :index, params: { casa_case_id: @casa_case1.id }
        
        # Access the instance variable that was set in the controller
        case_contacts_hash = assigns(:casa_case_id_to_case_contacts)
        
        # Should only include contacts from casa_case1
        expect(case_contacts_hash.keys).to contain_exactly(@casa_case1.id)
        expect(case_contacts_hash[@casa_case1.id]).to contain_exactly(@contact1, @contact2)
      end
    end

    context "when casa_case_id param is not present" do
      it "includes case contacts for all casa cases" do
        get :index
        
        case_contacts_hash = assigns(:casa_case_id_to_case_contacts)
        
        # Should include contacts from both cases
        expect(case_contacts_hash.keys).to contain_exactly(@casa_case1.id, @casa_case2.id)
        expect(case_contacts_hash[@casa_case1.id]).to contain_exactly(@contact1, @contact2)
        expect(case_contacts_hash[@casa_case2.id]).to contain_exactly(@contact3)
      end
    end
  end
end 