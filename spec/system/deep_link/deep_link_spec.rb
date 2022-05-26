require "rails_helper"

RSpec.describe "deep_link", type: :system do
  context "when user recieves a deep link" do
    %w[volunteer supervisor casa_admin].each do |user_type|
      let(:user) { create(user_type.to_sym) }

      it "redirects #{user_type} to target url" do
        visit "/users/edit"
        fill_in "Email", with: user.email
        fill_in "Password", with: "12345678"
        within ".actions" do
          click_on "Log in"
        end
        expect(current_path).to eq "/users/edit"
        expect(page).to have_text "Edit Profile"
      end
    end
  end
end
