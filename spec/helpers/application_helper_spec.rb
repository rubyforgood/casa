require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "#page_header" do
     it "links to the user dashboard if user logged in" do
      current_organization = build_stubbed(:casa_org)
      user = build_stubbed(:user, casa_org: current_organization)

      allow(helper).to receive(:user_signed_in?).and_return(true)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:current_organization).and_return(current_organization)

      dashboard_link = helper.link_to(current_organization.display_name, root_path)

      expect(helper.page_header).to eq(dashboard_link)
    end

    it "displays the header when user is not logged in" do
      allow(helper).to receive(:user_signed_in?).and_return(false)

      expect(helper.page_header).to eq(helper.default_page_header)
    end
  end

  describe "#session_link" do
    it "links to the sign_out page when user is signed in" do
      allow(helper).to receive(:user_signed_in?).and_return(true)

      expect(helper.session_link).to match(destroy_user_session_path)
    end

    it "links to the sign_in page when user is not signed in" do
      allow(helper).to receive(:user_signed_in?).and_return(false)
      allow(helper).to receive(:all_casa_admin_signed_in?).and_return(false)
      expect(helper.session_link).to match(new_user_session_path)
    end
  end
end