require "rails_helper"

RSpec.describe "Index Mileage Rates", type: :view do
  let(:admin) { build_stubbed :casa_admin }
  let(:mileage_rate) { build_stubbed :mileage_rate }

  before do
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
    sign_in admin
  end

  it "allows editing the mileage rate" do
    assign :mileage_rates, [mileage_rate]

    render template: "mileage_rates/index"
    expect(rendered).to have_link("Edit", href: "/mileage_rates/#{mileage_rate.id}/edit")
  end
end
