# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::TitleComponent, type: :component do
  let(:title) { "Record case contact" }
  let(:subtitle) { "Enter notes" }
  let(:step) { nil }
  let(:total_steps) { nil }
  let(:notes) { nil }
  let(:autosave) { nil }

  before(:each) do
    render_inline(described_class.new(title: title, subtitle: subtitle, step: step, total_steps: total_steps, notes: notes, autosave: autosave))
  end

  context "by default" do
    it "renders component" do
      expect(page).to have_css "h1", text: title
      expect(page).to have_css "h2", text: subtitle
    end

    it "does not render progress" do
      expect(page).not_to have_css "div[class='progress']"
    end

    it "does not render autosave alert div" do
      expect(page).not_to have_css "small[data-autosave-target='alert']"
    end
  end

  context "with step and total_steps" do
    let(:step) { 2 }
    let(:total_steps) { 5 }

    it "renders progress bar" do
      expect(page).to have_css "div[class='progress']"
    end

    it "renders steps in a phrase" do
      expect(page).to have_css "p", text: "Step 2 of 5"
    end

    it "renders progress bar with percentage" do
      expect(page).to have_css "div[style='width: 40.0%']"
    end
  end

  context "with notes" do
    let(:notes) { "Some notes to display" }

    it "renders notes" do
      expect(page).to have_css "p", text: notes
    end
  end

  context "with autosave" do
    let(:autosave) { true }

    it "renders autosave alert div" do
      expect(page).to have_css "small[data-autosave-target='alert']"
    end
  end
end
