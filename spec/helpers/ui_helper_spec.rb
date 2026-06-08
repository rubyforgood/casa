require "rails_helper"

RSpec.describe UiHelper, type: :helper do
  describe "#grouped_options_for_assigning_case" do
    before do
      @casa_case = create(:casa_case)
      @volunteer = create(:volunteer, casa_org: @casa_case.casa_org)
      current_user = create(:supervisor)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    it "does not render duplicate casa_case" do
      options = helper.grouped_options_for_assigning_case(@volunteer)

      expect(options[0]).to eq(options[0].uniq { |option| option[0] })
      expect(options[1]).to eq(options[1].uniq { |option| option[0] })
    end
  end
end
