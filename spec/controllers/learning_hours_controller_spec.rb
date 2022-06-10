require "rails_helper"

RSpec.describe LearningHoursController, type: :controller do
  let(:organization) { build(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
  end

  describe "index" do
    xit "shows learning hours for current user" do
      learning_hour_1 = create(:learning_hour, user: volunteer)
      learning_hour_2 = create(:learning_hour, user: volunteer)
      _learning_hour_other_user = create(:learning_hour, user: create(:volunteer))
      get :index, {volunteer_id: volunteer.id} # No route matches {:action=>"index", :controller=>"learning_hours"}
      expect(assigns(:learning_hours)).to match_array([learning_hour_1, learning_hour_2])
    end
  end

  describe "create" do
    it "creates a learning hour" do
      post :create, params: {name: "Learning Hour Name"}
      expect(response).to redirect_to volunteer_learning_hours_path(volunteer_id: volunteer.id)
      expect(assigns(:learning_hour).name).to eq("Learning Hour Name")
    end
  end
end
