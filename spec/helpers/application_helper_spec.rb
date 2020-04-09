require 'rails_helper'

describe ApplicationHelper do
  describe '#page_header' do
    let(:page_header_text) { "CASA - Prince George's County, MD" }

    it 'links to the user dashboard if user logged in' do
      allow(helper).to receive(:user_signed_in?) { true }
      dashboard_link = helper.link_to(page_header_text, root_path)

      expect(helper.page_header).to eq(dashboard_link)
    end

    it 'displays the header when user is not logged in' do
      allow(helper).to receive(:user_signed_in?) { false }

      expect(helper.page_header).to eq(page_header_text)
    end
  end

  describe '#session_link' do
    it 'links to the sign_out page when user is signed in' do
      allow(helper).to receive(:user_signed_in?) { true }

      expect(helper.session_link).to match(destroy_user_session_path)
    end

    it 'links to the sign_in page when user is not signed in' do
      allow(helper).to receive(:user_signed_in?) { false }

      expect(helper.session_link).to match(new_user_session_path)
    end
  end

  describe '#edit_profile_link' do
    it 'links to the edit volunteer path when user is signed in' do
      current_user = User.new(id: 1)
      allow(helper).to receive(:user_signed_in?) { true }
      allow(helper).to receive(:current_user) { current_user }

      expect(helper.edit_profile_link).to match(edit_volunteer_path(current_user))
    end

    it 'returns nothing if user is not signed in' do
      allow(helper).to receive(:user_signed_in?) { false }

      expect(helper.edit_profile_link).to be_nil
    end
  end
end
