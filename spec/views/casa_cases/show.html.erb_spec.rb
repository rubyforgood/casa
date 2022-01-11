require "rails_helper"

RSpec.describe "casa_cases/show", type: :view do
  let(:organization) { create(:casa_org) }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end
end
