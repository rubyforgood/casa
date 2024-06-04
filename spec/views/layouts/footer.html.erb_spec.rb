require "rails_helper"

RSpec.describe "layout/footer", type: :view do
  context "when not logged in" do
    it "renders report issue link on the footer" do
      render partial: "layouts/footers/not_logged_in"
      expect(rendered).to have_link("Report a site issue", href: "https://form.typeform.com/to/iXY4BubB")
    end

    it "renders SMS terms and conditions link on the footer" do
      render partial: "layouts/footers/not_logged_in"
      expect(rendered).to have_link("SMS Terms & Conditions", href: "/sms-terms-conditions.html")
    end

    it "renders Ruby For Good link on the footer" do
      render partial: "layouts/footers/not_logged_in"
      expect(rendered).to have_link("Ruby For Good", href: "https://rubyforgood.org/")
    end
  end

  context "when logged in" do
    it "renders report issue link on the footer" do
      render partial: "layouts/footers/logged_in"
      expect(rendered).to have_link("Report a site issue", href: "https://form.typeform.com/to/iXY4BubB")
    end

    it "renders SMS terms and conditions link on the footer" do
      render partial: "layouts/footers/logged_in"
      expect(rendered).to have_link("Terms & Conditions", href: "/sms-terms-conditions.html")
    end

    it "renders Ruby For Good link on the footer" do
      render partial: "layouts/footers/logged_in"
      expect(rendered).to have_link("Ruby For Good", href: "https://rubyforgood.org/")
    end
  end
end
