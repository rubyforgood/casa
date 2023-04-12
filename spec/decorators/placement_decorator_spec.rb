require "rails_helper"

RSpec.describe CaseContactDecorator do
  let(:placement) { build(:placement) }
  let(:date_string) { "April 14, 2023" }

  before do
    placement.update_attribute(:placement_started_at, Date.new(2023, 4, 14))
  end


  describe "#formatted_date" do
    it "returns correctly formatted date" do
      expect(placement.decorate.formatted_date).to eq date_string
    end
  end

  describe "#placement_info" do
    it "returns the correct placement info string" do
      expect(placement.decorate.placement_info).to eq "Started At:  #{date_string} - Placement Type: #{placement.placement_type.name}"
    end
  end
end
