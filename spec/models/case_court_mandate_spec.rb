require "rails_helper"

RSpec.describe CaseCourtMandate, type: :model do
  subject { build(:case_court_mandate) }

  it { is_expected.to belong_to(:casa_case) }

  it { is_expected.to validate_presence_of(:mandate_text) }
end
