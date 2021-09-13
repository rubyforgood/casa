require "rails_helper"

RSpec.describe SentEmail, type: :model do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:mailer_type) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:sent_address) }
end
