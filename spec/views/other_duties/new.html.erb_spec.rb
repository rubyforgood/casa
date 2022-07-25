require "rails_helper"

RSpec.describe "other_duties/new", type: :view do
  let(:current_time) { Time.zone.now.strftime("%Y-%m-%d") }

  before do
    assign :other_duty, OtherDuty.new
    render template: "other_duties/new"
  end

  it "display all form fields" do
    expect(rendered).to have_text("New Duty")
    expect(rendered).to have_field("Occurred On", with: current_time)
    expect(rendered).to have_text("Duty Duration")
    expect(rendered).to have_text("Enter Notes")
  end
end
