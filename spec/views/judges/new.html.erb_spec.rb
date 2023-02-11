require "rails_helper"

RSpec.describe "judges/new", type: :view do
  let(:admin) { build_stubbed(:casa_admin) }

  before do
    assign :judge, Judge.new
    sign_in admin

    render template: "judges/new"
  end

  it "shows new judge form" do
    expect(rendered).to have_text("New Judge")
    expect(rendered).to have_selector("input", id: "judge_name")
    expect(rendered).to have_selector("input", id: "judge_active")
    expect(rendered).to have_selector("button[type=submit]")
  end

  it "requires name text_field" do
    expect(rendered).to have_selector("input[required=required]", id: "judge_name")
  end
end
