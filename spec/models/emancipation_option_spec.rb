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

      it "is unique across emancipation_category, name" do
        eo = create(:emancipation_option)
        eo_new = build(:emancipation_option, emancipation_category: eo.emancipation_category, name: eo.name)
        expect(eo_new.valid?).to be false
      end

      it "creates two new entries given different categories and same names" do
        expect {
          build_stubbed(:emancipation_option, emancipation_category_id: non_duplicate_category.id, name: duplicate_option_name)
          build_stubbed(:emancipation_option, emancipation_category_id: duplicate_category.id, name: duplicate_option_name)
        }.not_to raise_error
      end
    end
  end

  describe ".category_options" do
    let(:category_a) { create(:emancipation_category, name: "A") }
    let(:category_b) { create(:emancipation_category, name: "B") }
    let(:option_a) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "A") }
    let(:option_b) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "B") }
    let(:option_c) { create(:emancipation_option, emancipation_category_id: category_a.id, name: "C") }
    let(:option_d) { create(:emancipation_option, emancipation_category_id: category_b.id, name: "D") }

    it "contains exactly the options belonging to the category passed to it" do
      expect(EmancipationOption.category_options(category_a.id)).to contain_exactly(option_a, option_b, option_c)
      expect(EmancipationOption.category_options(category_b.id)).to contain_exactly(option_d)
    end
  end

  describe ".options_with_category_and_case" do
    let(:case_a) { create(:casa_case) }
    let(:case_b) { create(:casa_case) }
    let(:category_a) { create(:emancipation_category, name: "A") }
    let(:category_b) { create(:emancipation_category, name: "B") }
    let(:option_a) { build(:emancipation_option, emancipation_category_id: category_a.id, name: "A") }
    let(:option_b) { build(:emancipation_option, emancipation_category_id: category_a.id, name: "B") }
    let(:option_c) { build(:emancipation_option, emancipation_category_id: category_a.id, name: "C") }
    let(:option_d) { build(:emancipation_option, emancipation_category_id: category_b.id, name: "D") }

    it "contains exactly the options belonging to the category and case passed to it" do
      case_a.emancipation_options += [option_a, option_b]
      case_b.emancipation_options += [option_b, option_d]

      expect(EmancipationOption.options_with_category_and_case(category_a.id, case_a.id)).to contain_exactly(option_a, option_b)
      expect(EmancipationOption.options_with_category_and_case(category_a.id, case_b.id)).to contain_exactly(option_b)
      expect(EmancipationOption.options_with_category_and_case(category_b.id, case_a.id)).to be_empty
      expect(EmancipationOption.options_with_category_and_case(category_b.id, case_b.id)).to contain_exactly(option_d)
    end
  end
end
