require "rails_helper"

describe "layout/footer", type: :view do
  context "when not logged in" do
    it "renders report issue link on the footer" do
      render partial: "layouts/footers/not_logged_in"
      expect(rendered).to have_link("Report a site issue", href: "https://rubyforgood.typeform.com/to/iXY4BubB")
    end
  end
end
