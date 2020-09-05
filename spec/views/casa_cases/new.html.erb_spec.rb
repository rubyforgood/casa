require "rails_helper"

describe "casa_cases/new" do
  subject { render template: "casa_cases/new" }

  before do
    assign :casa_case, CasaCase.new
  end

  context "while signed in as admin" do
    before do
      sign_in_as_admin
    end

    it { is_expected.to have_selector("a", text: "Return to Dashboard") }
  end
end
