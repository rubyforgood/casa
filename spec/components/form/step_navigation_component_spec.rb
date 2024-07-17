# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::StepNavigationComponent, type: :component do
  context "can handle enabled button" do
    it "enables button if value exists" do
      render_inline(described_class.new(nav_back: "/details"))
      expect(page).to have_selector(:link_or_button, "Back step")
    end
  end

  context "can handle disabled button" do
    it "disables buttons if value is nil" do
      render_inline(described_class.new)
      expect(page).not_to have_selector(:link_or_button, "Next step")
    end
  end
end
