require "rails_helper"

RSpec.describe "deep_link", type: :system do
  describe "when user recieves a deep link" do
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

    context "when volunteer or supervisor is visiting a casa_admin link" do
      let(:volunteer) { create(:volunteer) }
      let(:supervisor) { create(:supervisor) }

      before do
        visit "/casa_admins"
        fill_in "Password", with: "12345678"
      end

      it "flashes unauthorized message when volunteer tries to access a casa_admin link" do
        fill_in "Email", with: volunteer.email
        within ".actions" do
          click_on "Log in"
        end
        expect(page).to have_text "Sorry, you are not authorized to perform this action."
      end

      it "flashes unauthorized message when supervisor tries to access a casa_admin link" do
        fill_in "Email", with: supervisor.email
        within ".actions" do
          click_on "Log in"
        end
        expect(page).to have_text "Sorry, you are not authorized to perform this action."
      end
    end
  end
end
