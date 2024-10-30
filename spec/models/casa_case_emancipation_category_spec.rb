require "rails_helper"

RSpec.describe CasaCaseEmancipationCategory do
  subject(:casa_case_emancipation_category) { build_stubbed(:casa_case_emancipation_category) }

  specify do
    expect(subject).to belong_to(:casa_case)
    expect(subject).to belong_to(:emancipation_category)
  end

  it "does not allow adding the same category twice to a case" do
    casa_case = create(:casa_case)
    emancipation_category = create(:emancipation_category)
    casa_case.emancipation_categories << emancipation_category

    expect {
      casa_case.emancipation_categories << emancipation_category
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
