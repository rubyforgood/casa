require "rails_helper"

RSpec.describe "other_duties/new", type: :view do
  let(:current_time) { Time.zone.now.strftime("%Y-%m-%d") }

  before do
    assign :other_duty, OtherDuty.new
    render template: "other_duties/new"
  end

  it "display all form fields" do
    expect(rendered).to have_text("New duty")
    expect(rendered).to have_field("Occurred on", with: current_time)
    expect(rendered).to have_text("Duty duration")
    expect(rendered).to have_text("Enter notes")
  end
end
