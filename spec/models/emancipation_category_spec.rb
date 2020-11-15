require 'rails_helper'

RSpec.describe EmancipationCategory, type: :model do
  it { is_expected.to have_many(:emancipation_options) }
  it { is_expected.to validate_inclusion_of(:mutually_exclusive).in_array([ true, false ]) }
  it { is_expected.to validate_presence_of(:name) }

  context "When creating a new category" do
    it "creates a new category in the database" do
      expect {
        create(:emancipation_category)
      }.to change { EmancipationCategory.count }
    end

    it "raises an exception for duplicate entries" do
      duplicate_category_name = "test category"

      expect {
        create(:emancipation_category, name: duplicate_category_name)
        create(:emancipation_category, name: duplicate_category_name)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  context "#add_option" do
    let(:emancipation_category) { create(:emancipation_category) }

    after(:each) do
      EmancipationOption.category_options(emancipation_category.id).destroy_all
    end

    it "should call EmancipationOption.create" do
      option_name = "test option"

      expect(EmancipationOption).to receive(:create).with(emancipation_category_id: emancipation_category.id, name: option_name)
      emancipation_category.add_option(option_name)
    end
  end
end
