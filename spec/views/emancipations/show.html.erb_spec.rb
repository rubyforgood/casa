require "rails_helper"

RSpec.describe "emancipation/show", type: :view do
  subject { render template: "emancipation/show" }

  let(:organization) { build_stubbed(:casa_org) }
  let(:admin) { build_stubbed(:casa_admin, casa_org: organization) }
  let(:casa_case) { build_stubbed(:casa_case) }
  let(:emancipation_form_data) { [build_stubbed(:emancipation_category)] }

  before do
    assign :current_case, casa_case
    assign :emancipation_form_data, emancipation_form_data
  end

  it "has a link to return to case from emancipation" do
    sign_in admin
    render template: "emancipations/show"
    expect(rendered).to have_link(casa_case.case_number, href: "/casa_cases/#{casa_case.id}")
  end
end
