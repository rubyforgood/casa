require "rails_helper"

RSpec.describe AdditionalExpense, type: :model do
  it { is_expected.to belong_to(:case_contact) }
end
