require "rails_helper"

RSpec.describe CasaCaseContactType, type: :model do
  it "does not allow adding the same contact type twice to a case" do
    expect {
      casa_case = create(:casa_case)
      contact_type = create(:contact_type)

      casa_case.contact_types << contact_type
      casa_case.contact_types << contact_type
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
