require "rails_helper"

RSpec.describe Followup do
  subject { build(:followup) }

  it { is_expected.to belong_to(:case_contact) }
  it { is_expected.to belong_to(:creator).class_name("User") }
end
