require "rails_helper"

RSpec.describe "shared/_page_header", type: :view do
  def render_header(locals)
    render partial: "shared/page_header", locals: locals
  end

  it "renders the title as an h1" do
    render_header(title: "New volunteer")
    expect(rendered).to have_css("h1", text: "New volunteer")
  end

  it "renders the back link above the title and gives the title mt-2" do
    render_header(back: {path: "/volunteers", label: "Back to volunteers"}, title: "New volunteer")
    expect(rendered).to have_link("Back to volunteers", href: "/volunteers")
    expect(rendered).to have_css("h1.mt-2", text: "New volunteer")
  end

  it "omits mt-2 on the title when there is no back link" do
    render_header(title: "New volunteer")
    expect(rendered).to have_no_css("h1.mt-2")
  end

  it "renders an optional subtitle under the title" do
    render_header(title: "Edit profile", subtitle: "Manage your details.")
    expect(rendered).to have_css("p", text: "Manage your details.")
  end

  it "omits the subtitle when not given" do
    render_header(title: "New volunteer")
    expect(rendered).to have_no_css("p")
  end

  it "applies an optional wrapper_class to the outer div" do
    render_header(title: "New case", wrapper_class: "mb-6")
    expect(rendered).to have_css("div.mb-6")
  end
end
