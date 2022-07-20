require "rails_helper"

RSpec.describe "other_duties/edit", type: :view do
  let(:other_duty) { create(:other_duty) }

  before do
    assign :other_duty, other_duty
  end

  it "display all form fields" do
    render template: "other_duties/edit"

    expect(rendered).to have_text("Editing Duty")
    expect(rendered).to have_text("Occurred On")
    expect(rendered).to have_text("Duty Duration")
    expect(rendered).to have_text("Enter Notes")
  end

  it "displays occurred time in the occurred at form field" do
    render template: "other_duties/edit"

    expect(rendered).to include(other_duty.occurred_at.strftime("%Y-%m-%d"))
  end

  it "displays notes in the notes form field" do
    render template: "other_duties/edit"

    expect(rendered).to include(CGI.escapeHTML(other_duty.notes))
  end
end
