require "rails_helper"

RSpec.describe LoadsCaseContacts do
  let(:host) do
    Class.new do
      include LoadsCaseContacts
    end
  end

  it "exists and defines private API" do
    expect(described_class).to be_a(Module)
    expect(host.private_instance_methods)
      .to include(:load_case_contacts, :current_organization_groups, :all_case_contacts)
  end

  describe "integration with Flipper flags", type: :request do
    let(:organization) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: organization) }
    let!(:casa_case) { create(:casa_case, casa_org: organization) }
    let!(:case_contact) { create(:case_contact, :active, casa_case: casa_case) }

    before { sign_in admin }

    context "when new_case_contact_table flag is enabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(true)
      end

      it "loads case contacts successfully through the new design controller" do
        get case_contacts_new_design_path
        expect(response).to have_http_status(:success)
        expect(assigns(:filtered_case_contacts)).to be_present
      end
    end

    context "when new_case_contact_table flag is disabled" do
      before do
        allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(false)
      end

      it "does not load case contacts and redirects instead" do
        get case_contacts_new_design_path
        expect(response).to redirect_to(case_contacts_path)
        expect(assigns(:filtered_case_contacts)).to be_nil
      end
    end
  end
end
