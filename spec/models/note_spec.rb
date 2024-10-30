require "rails_helper"

RSpec.describe Note, type: :model do
  subject(:note) { build_stubbed(:note) }

  specify do
    expect(subject).to belong_to(:notable)
    expect(subject).to belong_to(:creator)
  end
end
