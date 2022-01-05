require "rails_helper"

RSpec.describe Health, type: :model do
  describe "#instance" do
    it "returns an instance of the health class" do
      expect(Health.instance).not_to eq nil
    end

    it "returns a new instance of the health class if there are none" do
      Health.destroy_all
      expect(Health.instance).not_to eq nil
    end

    it "singleton_guard column is 0" do
      expect(Health.instance.singleton_guard).to eq 0
    end
  end
end
