require "rails_helper"

RSpec.describe "emancipation/show", :disable_bullet, type: :view do
  subject { render template: "emancipation/show" }

  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case) }
  let(:emancipation_form_data) { [create(:emancipation_category)] }

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
