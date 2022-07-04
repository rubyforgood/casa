require "rails_helper"

RSpec.describe PatchNote, type: :model do
  let!(:patch_note) { create(:patch_note) }

  it { is_expected.to belong_to(:patch_note_group) }
  it { is_expected.to belong_to(:patch_note_type) }
  it { is_expected.to validate_presence_of(:note) }
end
