# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::HourMinuteDurationComponent, type: :component do
  let(:case_contact) { build(:case_contact) }
  let(:form_builder) { ActionView::Helpers::FormBuilder.new(:object, double("object"), ActionView::Base.new(ActionView::LookupContext.new("app/views"), {}, ActionController::Base.new), {}) }

  it "has initial values set by the component" do
    minute_value = "1112"
    hour_value = 256

    component = described_class.new(form: form_builder, hour_value: hour_value, minute_value: minute_value)
    render_inline(component)

    expect(page.find_css("input[type=number][value=#{minute_value}]").length).to eq(1)
    expect(page.find_css("input[type=number][value=#{hour_value}]").length).to eq(1)
  end

  it "throws errors for incorrect parameters" do
    expect {
      described_class.new(form: form_builder, hour_value: "Not a number", minute_value: 10)
    }.to raise_error(ArgumentError)

    expect {
      described_class.new(form: form_builder, hour_value: 10, minute_value: -10)
    }.to raise_error(RangeError)

    expect {
      described_class.new(form: form_builder, hour_value: 10, minute_value: "-10")
    }.to raise_error(RangeError)

    expect {
      described_class.new(form: form_builder, hour_value: false, minute_value: "10")
    }.to raise_error(TypeError)
  end
end
