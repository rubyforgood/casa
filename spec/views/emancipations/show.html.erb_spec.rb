require "rails_helper"

RSpec.describe "emancipation/show", type: :view do
  subject { render template: "emancipation/show" }

  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case) }
  let(:emancipation_form_data) { [create(:emancipation_category)] }


  before do
    assign :current_case, casa_case
    assign :emancipation_form_data, emancipation_form_data

    # enable_pundit(view, user)
    # allow(view).to receive(:current_user).and_return(user)
    # allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  it "has a link to return to case from emancipation" do
    sign_in admin
    render template: "emancipations/show"

    # old:
    # expect(rendered).to have_link(:casa_case.id, "/casa_cases/#{:casa_case.id}")


    expect(rendered).to have_link(:casa_case.case_number, "/casa_cases/#{:casa_case.id}")
  end
end
