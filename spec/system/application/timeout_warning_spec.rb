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
      expect(parsed_page.at('script').text.strip).to include(user.timeout_in.in_seconds.to_s)
    end

    xit "warns the user two mintues before logout", js: true do
      # visit "/"
      # travel_to(user.timeout_in.from_now - 2.minutes - 1.seconds) do
      #   sleep 2
      #   Capybara.using_wait_time(5) do
      #     begin
      #       wait = Selenium::WebDriver::Wait.new(timeout: 5) # Set a timeout limit

      #       expect(page).to have_text("############################")
      #       # expect(alert.text).to include('known_text') # Replace 'known_text' with expected text
      #       # alert.accept
      #     rescue Selenium::WebDriver::Error::TimeoutError
      #       fail "Alert did not appear in time"
          end
        end
      end
    end
  end
end