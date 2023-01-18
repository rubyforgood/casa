require "rails_helper"

RSpec.describe "deep_link", type: :system do
  describe "when user recieves a deep link" do
    %w[volunteer supervisor casa_admin].each do |user_type|
      let(:user) { create(user_type.to_sym) }

      it "redirects #{user_type} to target url immediately after sign in" do
        visit "/users/edit"
        fill_in "Email", with: user.email
        fill_in "Password", with: "12345678"
        within ".actions" do
          find("#log-in").click
        end
        expect(current_path).to eq "/users/edit"
        expect(page).to have_text "Edit Profile"
      end
    end

    context "when user is a volunteer or supervisor" do
      %w[volunteer supervisor].each do |user_type|
        let(:user) { create(user_type.to_sym) }

        it "flashes unauthorized notice when #{user_type} tries to access a casa_admin link" do
          visit "/casa_admins"
          fill_in "Email", with: user.email
          fill_in "Password", with: "12345678"
          within ".actions" do
            find("#log-in").click
          end
          expect(page).to have_text "Sorry, you are not authorized to perform this action."
        end
      end

      let(:volunteer) { create(:volunteer) }

      it "flashes unauthorized notice when volunteer tries to access a supervisor link" do
        visit "/supervisors"
        fill_in "Email", with: volunteer.email
        fill_in "Password", with: "12345678"
        within ".actions" do
          find("#log-in").click
        end
        expect(page).to have_text "Sorry, you are not authorized to perform this action."
      end
    end
  end
end
