require "rails_helper"

RSpec.describe CaseContact, type: :model do
  it { is_expected.to(belong_to(:creator).class_name("User")) }
  it { is_expected.to(belong_to(:casa_case)) }
  it { is_expected.to(validate_presence_of(:contact_types)) }
end
