require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#page_header" do
    it "displays the header when user is logged in" do
      current_organization = build_stubbed(:casa_org)
      user = build_stubbed(:user, casa_org: current_organization)

      allow(helper).to receive(:user_signed_in?).and_return(true)
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:current_organization).and_return(current_organization)

      expect(helper.page_header).to eq(current_organization.display_name)
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

    it "links to the sign_out page when all_casa_admin is signed in" do
      allow(helper).to receive(:user_signed_in?).and_return(false)
      allow(helper).to receive(:all_casa_admin_signed_in?).and_return(true)

      expect(helper.session_link).to match(destroy_all_casa_admin_session_path)
    end

    it "links to the sign_in page when user is not signed in" do
      allow(helper).to receive(:user_signed_in?).and_return(false)
      allow(helper).to receive(:all_casa_admin_signed_in?).and_return(false)
      expect(helper.session_link).to match(new_user_session_path)
    end
  end

  describe "#og_tag" do
    subject { helper.og_tag(:title, content: "Website Title") }

    it { is_expected.to eql('<meta property="og:title" content="Website Title">') }
  end
end
