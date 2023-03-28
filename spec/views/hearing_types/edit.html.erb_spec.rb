require "rails_helper"

RSpec.describe "hearing_types/edit", type: :view do
  let(:admin) { build_stubbed(:casa_admin) }

  before do
    assign :hearing_type, HearingType.new
    sign_in admin

    render template: "hearing_types/edit"
  end

  it "shows edit hearing type form" do
    expect(rendered).to have_text("Edit")
    expect(rendered).to have_selector("input", id: "hearing_type_name")
    expect(rendered).to have_selector("input", id: "hearing_type_active")
    expect(rendered).to have_selector("button[type=submit]")
  end

  it "requires name text_field" do
    expect(rendered).to have_selector("input[required=required]", id: "hearing_type_name")
  end
end
