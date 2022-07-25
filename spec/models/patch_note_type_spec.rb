require "rails_helper"

RSpec.describe PatchNoteType, type: :model do
  let!(:patch_note_type) { create(:patch_note_type) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
end
