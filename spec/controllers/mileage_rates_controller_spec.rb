require "rails_helper"

RSpec.describe MileageRatesController, type: :controller do
  describe "#index" do
    it "render the mileage rates by effective date in ascending order" do
      mileage_rate1 = FactoryBot.create(:mileage_rate, effective_date: Date.new(2023, 3, 1))
      mileage_rate2 = FactoryBot.create(:mileage_rate, effective_date: Date.new(2023, 1, 1))
      mileage_rate3 = FactoryBot.create(:mileage_rate, effective_date: Date.new(2023, 2, 1))
      mileage_rates = MileageRate.order(effective_date: :asc)
      get :index
      expect(mileage_rates).to eq([mileage_rate2, mileage_rate3, mileage_rate1])
    end
  end
end
