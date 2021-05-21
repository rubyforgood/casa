require "rails_helper"

RSpec.describe "layout/footer", :disable_bullet, type: :view do
  context "when not logged in" do
    it "renders report issue link on the footer" do
      render partial: "layouts/footers/not_logged_in"
      expect(rendered).to have_link("Report a site issue", href: "https://rubyforgood.typeform.com/to/iXY4BubB")
    end
  end
end
