require "rails_helper"

RSpec.describe TruncatedTextComponent, type: :system do
  it "renders the component with the provided text", js: true do
    visit("/rails/view_components/truncated_text_component/default")

    aggregate_failures do
      expect(page).to have_css(".truncation-container")
      expect(page).to have_css(".line-clamp-1")
      expect(page).to have_css("a", text: "[read more]")
      expect(page).to have_css("a", text: "[hide]", visible: false)
    end

    click_on "read more"

    aggregate_failures do
      expect(page).to have_no_css(".line-clamp-1")
      expect(page).to have_css("a", text: "[read more]", visible: false)
      expect(page).to have_css("a", text: "[hide]", visible: true)
    end
  end
end
