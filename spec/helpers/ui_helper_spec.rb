require "rails_helper"

RSpec.describe UiHelper do
  describe "#grouped_options_for_assigning_case" do
    before(:each) do
      @casa_cases = create_list(:casa_case, 4)
      @volunteer = create(:volunteer, casa_org: @casa_cases[0].casa_org)
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
