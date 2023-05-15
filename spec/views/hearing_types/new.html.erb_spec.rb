require "rails_helper"

RSpec.describe "hearing_types/new", type: :view do
  let(:admin) { build_stubbed(:casa_admin) }

  before do
    assign :hearing_type, HearingType.new
    sign_in admin

    render template: "hearing_types/new"
  end

  it "shows new hearing type form" do
    expect(rendered).to have_text("New Hearing Type")
    expect(rendered).to have_selector("input", id: "hearing_type_name")
    expect(rendered).to have_selector("input", id: "hearing_type_active")
    expect(rendered).to have_selector(:link_or_button, "Submit")
  end

  it "requires name text_field" do
    expect(rendered).to have_selector("input[required=required]", id: "hearing_type_name")
  end
end
