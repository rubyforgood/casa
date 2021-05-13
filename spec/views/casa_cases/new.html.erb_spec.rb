require "rails_helper"

RSpec.describe "casa_cases/new", :disable_bullet, type: :view do
  subject { render template: "casa_cases/new" }

  before do
    assign :casa_case, CasaCase.new
    assign :contact_types, []

    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "while signed in as admin" do
    let(:user) { build_stubbed(:casa_admin) }

    before do
      sign_in user
    end

    it { is_expected.to have_selector("a", text: "Back") }
    it { is_expected.to include(CGI.escapeHTML("Youth's Birth Month & Year")) }
  end

  context "while signed in as supervisor" do
    let(:user) { build_stubbed(:supervisor) }

    before do
      sign_in user
    end

    it { is_expected.to have_selector("a", text: "Back") }
    it { is_expected.not_to include(CGI.escapeHTML("Youth's Birth Month & Year")) }
    it { is_expected.to have_selector("label", text: "Contact types") }
  end
end
