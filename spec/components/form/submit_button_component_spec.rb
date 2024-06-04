# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::SubmitButtonComponent, type: :component do
  before(:each) do
    render_inline(described_class.new(last_step: last_step, current_step: current_step))
  end

  context "when last step is equal to current step" do
    let(:last_step) { :notes }
    let(:current_step) { :notes }
    it "renders Submit button" do
      expect(page).to have_content("Submit")
    end
  end

  context "when last step is not equal to current step" do
    let(:last_step) { :notes }
    let(:current_step) { :expenses }
    it "renders Save and continue button" do
      expect(page).to have_content("Save and continue")
    end
  end
end
