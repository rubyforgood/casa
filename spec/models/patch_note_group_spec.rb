require "rails_helper"

RSpec.describe PatchNoteGroup, type: :model do
  let!(:patch_note_group) { create(:patch_note_group, value: "test") }

  it { is_expected.to validate_uniqueness_of(:value) }
  it { is_expected.to validate_presence_of(:value) }
end
