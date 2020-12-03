require "rails_helper"

RSpec.describe EmancipationOption, type: :model do
  it { is_expected.to belong_to(:emancipation_category) }
  it { is_expected.to have_many(:casa_cases_emancipation_options).dependent(:destroy) }
  it { is_expected.to have_many(:casa_cases).through(:casa_cases_emancipation_options) }
  it { is_expected.to validate_presence_of(:name) }

  context "When creating a new option" do
    context "duplicate name entries" do
      duplicate_option_name = "test option"
      let(:duplicate_category) { create(:emancipation_category) }
      let(:non_duplicate_category) { create(:emancipation_category, name: "Not the same name as the other category to satisfy unique contraints") }

      it "raises an exception for entries with the same name and category" do
        duplicate_option_name = "test option"
        expect {
          create(:emancipation_option, emancipation_category: duplicate_category, name: duplicate_option_name)
          create(:emancipation_option, emancipation_category: duplicate_category, name: duplicate_option_name)
        }.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it "creates two new entries given different categories and same names" do
        expect {
          create(:emancipation_option, emancipation_category_id: non_duplicate_category.id, name: duplicate_option_name)
          create(:emancipation_option, emancipation_category_id: duplicate_category.id, name: duplicate_option_name)
        }.to_not raise_error
      end
    end
  end

  context ".category_options" do
    let(:category_a) { create(:emancipation_category, name: "A") }
    let(:category_b) { create(:emancipation_category, name: "B") }
    let(:option_a) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "A") }
    let(:option_b) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "B") }
    let(:option_c) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "C") }
    let(:option_d) { create(:emancipation_option, emancipation_category_id: category_b.id, name: "D") }

    it "contains exactly the options belonging to the category passed to it" do
      expect(EmancipationOption.category_options(category_a.id)).to match_array([option_a, option_b, option_c])
      expect(EmancipationOption.category_options(category_b.id)).to match_array([option_d])
    end
  end

  context ".options_with_category_and_case" do
    let(:case_a) { create(:casa_case) }
    let(:case_b) { create(:casa_case) }
    let(:category_a) { create(:emancipation_category, name: "A") }
    let(:category_b) { create(:emancipation_category, name: "B") }
    let(:option_a) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "A") }
    let(:option_b) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "B") }
    let(:option_c) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "C") }
    let(:option_d) { create(:emancipation_option, emancipation_category_id: category_b.id, name: "D") }

    it "contains exactly the options belonging to the category and case passed to it" do
      case_a.emancipation_options += [option_a, option_b]
      case_b.emancipation_options += [option_b, option_d]

      expect(EmancipationOption.options_with_category_and_case(category_a.id, case_a.id)).to match_array([option_a, option_b])
      expect(EmancipationOption.options_with_category_and_case(category_a.id, case_b.id)).to match_array([option_b])
      expect(EmancipationOption.options_with_category_and_case(category_b.id, case_a.id)).to match_array([])
      expect(EmancipationOption.options_with_category_and_case(category_b.id, case_b.id)).to match_array([option_d])
    end
  end
end
