require "rails_helper"

RSpec.describe EmancipationCategory, type: :model do
  specify do
    expect(subject).to have_many(:casa_case_emancipation_categories).dependent(:destroy)
    expect(subject).to have_many(:casa_cases).through(:casa_case_emancipation_categories)
    expect(subject).to have_many(:emancipation_options)

    expect(subject).to validate_presence_of(:name)
  end

  context "When creating a new category" do
    it "raises an exception for duplicate entries" do
      duplicate_category_name = "test category"

      expect {
        create(:emancipation_category, name: duplicate_category_name)
        create(:emancipation_category, name: duplicate_category_name)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "#add_option" do
    let(:emancipation_category) { create(:emancipation_category) }

    after do
      EmancipationOption.category_options(emancipation_category.id).destroy_all
    end

    it "creates an option" do
      option_name = "test option"

      expect {
        emancipation_category.add_option(option_name)
      }.to change(EmancipationOption, :count).by(1)
    end
  end

  describe "#delete_option" do
    let(:emancipation_category) { create(:emancipation_category) }

    after do
      EmancipationOption.category_options(emancipation_category.id).destroy_all
    end

    it "deletes an existing option" do
      option_name = "test option"

      emancipation_category.add_option(option_name)

      expect {
        emancipation_category.delete_option(option_name)
      }.to change(EmancipationOption, :count).by(-1)
    end
  end
end
