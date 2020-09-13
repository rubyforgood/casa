require "rails_helper"

RSpec.describe "view supervisor edit", type: :system do
  context "when the current user is a supervisor" do
    before do
      sign_in current_supervisor
    end

    let(:current_supervisor) { create(:supervisor) }

    it "does not have a submit button" do
      other_supervisor = create(:supervisor)

      visit edit_supervisor_path(other_supervisor)

      expect(page).not_to have_selector(:link_or_button, "Submit")
    end

    context "when the current user is editing self" do
      it "displays a submit button" do
        visit edit_supervisor_path(current_supervisor)

        expect(page).to have_selector(:link_or_button, "Submit")
      end
    end
  end

  context "when the current user is an casa_admin" do
    before do
      sign_in create(:casa_admin)
    end

    let(:supervisor) { create(:supervisor, :with_volunteers) }

    context "when entering valid information" do
      it "updates the e-mail address successfully" do
        visit edit_supervisor_path(supervisor)

        expect {
          fill_in "supervisor_email", with: ""
          fill_in "supervisor_email", with: "new" + supervisor.email
          click_on "Submit"
          page.find ".header-flash > div"
          supervisor.reload
        }.to change {supervisor.email}.to "new" + supervisor.email
      end
    end

    context "when the email exists already" do
      let!(:existing_supervisor) { create(:supervisor) }

      it "responds with a notice" do
        visit edit_supervisor_path(supervisor)
        fill_in "supervisor_email", with: ""
        fill_in "supervisor_email", with: existing_supervisor.email
        click_on "Submit"

        within "#error_explanation" do
          expect(page).to have_content(/already been taken/i)
        end
      end
    end
  end
end
