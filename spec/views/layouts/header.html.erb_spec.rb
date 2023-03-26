require "rails_helper"

module PretenderContext
  def true_user
  end
end

RSpec.describe "layout/header", type: :view do
  before do
    view.class.include PretenderContext
    allow(view).to receive(:true_user).and_return(user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_role).and_return(user.role)
  end

  context "when logged in as a casa admin" do
    let(:user) { build_stubbed :casa_admin }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match '<strong>Role: Casa Admin</strong>'
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end
  end

  context "when logged in as a supervisor" do
    let(:user) { build_stubbed :supervisor }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match '<strong>Role: Supervisor</strong>'
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end
  end

  context "when logged in as a volunteer" do
    let(:user) { build_stubbed :volunteer }

    it "renders user information", :aggregate_failures do
      sign_in user

      render partial: "layouts/header"

      expect(rendered).to match '<strong>Role: Volunteer</strong>'
      expect(rendered).to match CGI.escapeHTML user.display_name
      expect(rendered).to match CGI.escapeHTML user.email
    end
  end

  context "notifications" do
    let(:user) { build_stubbed :casa_admin }

    it "displays unread notification count if the user has unread notifications" do
      sign_in user
      build_stubbed(:notification)
      allow(user).to receive_message_chain(:notifications, :unread).and_return([:notification])

      render partial: "layouts/header"

      expect(rendered).to match '<span>1</span>'
    end

    it "does not display unread notification count if the user has no unread notifications" do
      sign_in user
      allow(user).to receive_message_chain(:notifications, :unread).and_return([])

      render partial: "layouts/header"

      expect(rendered).not_to match '<span>0</span>'
    end
  end

  context "impersonation" do
    let(:user) { build_stubbed :volunteer }
    let(:true_user) { build_stubbed :casa_admin }

    it "renders correct role name when impersonating a volunteer" do
      allow(view).to receive(:true_user).and_return(true_user)

      render partial: "layouts/header"

      expect(rendered).to match '<strong>Role: Volunteer</strong>'
    end
  end
end
