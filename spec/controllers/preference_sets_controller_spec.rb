require "rails_helper"

RSpec.describe PreferenceSetsController, type: :controller do
  describe "#create" do
    def log_in_as_supervisor
      @east = create :casa_org, name: "East"
      @supervisor = create :supervisor, casa_org: @east
      allow(controller).to receive(:current_user).and_return(@supervisor)
    end

    xit "creates a preference_set relationship" do
      allow(controller).to receive(:authenticate_user!).and_return(:supervisor)
      log_in_as_supervisor
      expect {
        post :create, params: { preference_set: { name: "email" } }
      }.to change(PreferenceSet, :count).by(1)
    end
  end
end
