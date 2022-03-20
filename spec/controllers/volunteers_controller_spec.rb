require "rails_helper"

RSpec.describe VolunteersController, type: :controller do
  describe "update" do
    context "as a supervisor" do
      it "only shows volunteers for the same casa org" do
        east = create :casa_org, name: "East"
        west = create :casa_org, name: "West"
        supervisor = create :supervisor, casa_org: east
        allow(controller).to receive(:authenticate_user!).and_return(:supervisor)
        allow(controller).to receive(:current_user).and_return(supervisor)
        volunteer_east = create :volunteer, casa_org: east
        _volunteer_west = create :volunteer, casa_org: west
        get :edit, params: {id: volunteer_east.id}
        expect(response).to have_http_status(:ok)
        expect(assigns(:supervisors)).to eq([supervisor])
        expect(assigns(:volunteer)).to eq(volunteer_east)
      end

      it "cannot edit volunteer for a different casa org" do
        east = create :casa_org, name: "East"
        west = create :casa_org, name: "West"
        supervisor = create :supervisor, casa_org: east
        allow(controller).to receive(:authenticate_user!).and_return(:supervisor)
        allow(controller).to receive(:current_user).and_return(supervisor)
        volunteer_west = create :volunteer, casa_org: west
        get :edit, params: {id: volunteer_west.id}
        expect(response).to redirect_to("/")
      end
    end
  end
end
