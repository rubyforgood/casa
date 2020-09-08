require "rails_helper"

describe ApplicationHelper do
  describe "#page_header" do
    let(:page_header_text) { "CASA / Prince George's County, MD" }

    it "links to the user dashboard if user logged in" do
      allow(helper).to receive(:user_signed_in?).and_return(true)
      dashboard_link = helper.link_to(page_header_text, root_path)

      expect(helper.page_header).to eq(dashboard_link)
    end

    it "displays the header when user is not logged in" do
      allow(helper).to receive(:user_signed_in?).and_return(false)

      expect(helper.page_header).to eq(page_header_text)
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
