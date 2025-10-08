require "rails_helper"

RSpec.describe FundRequest, type: :model do
  it { is_expected.to validate_presence_of(:submitter_email) }
end
