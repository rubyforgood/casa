require "rails_helper"

RSpec.describe PatchNote do
  let!(:patch_note) { build_stubbed(:patch_note) }

  specify do
    expect(subject).to belong_to(:patch_note_group).optional(false)
    expect(subject).to belong_to(:patch_note_type).optional(false)
    expect(subject).to validate_presence_of(:note)
  end
end
