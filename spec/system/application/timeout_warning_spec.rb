require "rails_helper"

RSpec.describe "/*", type: :system do
  context "when user is signed in" do
    let(:user) { create(:volunteer) }
    before do
      sign_in user
    end
    it "renders the seconds before logout as a javascript variable" do
      visit "/"
      parsed_page = Nokogiri::HTML(page.html)
      expect(parsed_page.at("script").text.strip).to include(user.timeout_in.in_seconds.to_s)
    end
  end
end
