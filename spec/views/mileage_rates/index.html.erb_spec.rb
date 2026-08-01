require "rails_helper"

RSpec.describe "Index Mileage rates", type: :view do
  let(:admin) { build_stubbed :casa_admin }
  let(:mileage_rate) { build_stubbed :mileage_rate }

  before do
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
    # The settings rail this page renders links to edit_casa_org_path(current_organization). An
    # org-scoped helper left unstubbed in a view spec does not raise NoMethodError -- `helper_method`
    # generates `def current_organization(...) _test_case.send(:current_organization, ...) end`, so it
    # recurses between the view and the example group until SystemStackError.
    allow(view).to receive(:current_organization).and_return(admin.casa_org)
    sign_in admin
  end

  it "allows editing the mileage rate" do
    assign :mileage_rates, [mileage_rate]

    render template: "mileage_rates/index"
    expect(rendered).to have_link("Edit", href: "/mileage_rates/#{mileage_rate.id}/edit")
  end
end
