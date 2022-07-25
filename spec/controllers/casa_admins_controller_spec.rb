require "rails_helper"

RSpec.describe CasaAdminsController, type: :controller do
  def log_in_as_supervisor
    @supervisor = create :supervisor, casa_org: @east
    allow(controller).to receive(:current_user).and_return(@supervisor)
  end

  def log_in_as_admin
    @admin = create :casa_admin
    allow(controller).to receive(:current_user).and_return(@admin)
  end

  it "renders the :index view" do
    allow(controller).to receive(:authenticate_user!).and_return(:supervisor)
    log_in_as_admin
    get :index
    expect(response).to be_successful
  end
end