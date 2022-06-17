require "rails_helper"

RSpec.describe PatchNoteType, type: :model do
  it "does not have duplicate names" do
    create_patch_note_type = -> { create(:contact_type_group, {name: "Test1"}) }
    create_patch_note_type.call
    expect { create_patch_note_type.call }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Name has already been taken")
  end
end
