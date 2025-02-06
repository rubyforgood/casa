require "rails_helper"

RSpec.describe "case_contacts/index", type: :view do
  let(:user) { build_stubbed(:volunteer) }
  let(:case_contacts) { CaseContact.all }
  let(:pagy) { Pagy.new(count: 0) }

  let(:filterrific_param_set) do
    param_set = Filterrific::ParamSet.new(case_contacts, {})
    param_set.select_options = {sorted_by: CaseContact.options_for_sorted_by}

    param_set
  end

  let(:groups) do
    user.casa_org.contact_type_groups
      .joins(:contact_types)
      .where(contact_types: {active: true})
      .uniq
  end

  before do
    enable_pundit(view, user)

    # Allow filterrific to fetch the correct controller name
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("case_contacts")

    allow(RequestStore).to receive(:read).with(:current_user).and_return(user)
    allow(RequestStore).to receive(:read).with(:current_organization).and_return(user.casa_org)

    assign(:current_organization_groups, groups)
    assign(:filterrific, filterrific_param_set)
    assign(:presenter, CaseContactPresenter.new(case_contacts))
    assign(:pagy, pagy)

    render template: "case_contacts/index"
  end

  it "Displays the Case Contacts title" do
    expect(rendered).to have_text("Case Contacts")
  end

  it "Has a New Case Contact button" do
    expect(rendered).to have_link("New Case Contact", href: new_case_contact_path)
  end
end
