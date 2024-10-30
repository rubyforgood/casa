require "rails_helper"

RSpec.describe SentEmail, type: :model do
  subject(:sent_email) { build_stubbed(:sent_email) }

  specify do
    expect(subject).to belong_to(:casa_org)
    expect(subject).to belong_to(:user)
    expect(subject).to validate_presence_of(:mailer_type)
    expect(subject).to validate_presence_of(:category)
    expect(subject).to validate_presence_of(:sent_address)
  end
end
