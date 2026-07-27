require "rails_helper"

RSpec.describe "casa_app shell footer", type: :system do
  it "shows the support + SMS-compliance links to signed-in chapter users" do
    sign_in create(:casa_admin)
    visit volunteers_path

    within "footer" do
      expect(page).to have_link("Report a site issue", href: "https://form.typeform.com/to/iXY4BubB")
      expect(page).to have_link("SMS Terms & Conditions", href: "/sms-terms-conditions.html")
      expect(page).to have_link("Ruby For Good", href: "https://rubyforgood.org/")
    end
  end
end
