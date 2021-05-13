require "rails_helper"

RSpec.describe "case_contacts/index", :disable_bullet, type: :view do
  let(:user) { build_stubbed(:volunteer) }

  before do
    enable_pundit(view, user)
    allow(RequestStore).to receive(:read).with(:current_user).and_return(user)
    allow(RequestStore).to receive(:read).with(:current_organization).and_return(user.casa_org)
    assign(:presenter, CaseContactPresenter.new)
    render template: "case_contacts/index"
  end

  it "Displays the Case Contacts title" do
    expect(rendered).to have_text("Case Contacts")
  end

  it "Has a New Case Contact button" do
    expect(rendered).to have_link("New Case Contact", href: new_case_contact_path)
  end
end
