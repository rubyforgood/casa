require "rails_helper"

RSpec.describe "layouts/application", type: :view do
  subject { rendered }

  let(:title) { "CASA Volunteer Tracking" }
  let(:description) { "Volunteer activity tracking for CASA volunteers, supervisors, and administrators." }

  it "renders correct title" do
    render
    expect(subject).to match "<title>#{title}</title>"
  end

  it "renders correct description" do
    render
    expect(subject).to match "<meta name=\"description\" content=\"#{description}\">"
  end

  it "renders correct og meta tags" do
    render

    expect(rendered.scan(/<meta property="og:.*>/).count).to be(4)
    expect(subject).to match("og:title\" content=\"#{title}\"")
    expect(subject).to match('og:url" content="http://test.host/"')
    expect(subject).to match('og:image" content="http://test.host/assets/.*.jpg"')
    expect(subject).to match(
      'og:description" content="Volunteer activity tracking for CASA volunteers, supervisors, and administrators."'
    )
  end
end
