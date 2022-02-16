require "rails_helper"

RSpec.describe AllCasaAdmins::CasaAdminsController, type: :controller do
  let(:casa_org) { create(:casa_org) }
  xit "show" do
    # TODO fix error: No route matches
    get :show, params: {slug: casa_org.slug}
    expect(response).to be_truthy
  end
end
