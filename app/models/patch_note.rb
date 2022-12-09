class PatchNote < ApplicationRecord
  validates :note, presence: true

  belongs_to :patch_note_type
  belongs_to :patch_note_group

  scope :notes_available_for_user, ->(user) {
    joins(:patch_note_group)
      .where("POSITION(? IN value)>0", user.type)
      .where("patch_notes.created_at < ?", Health.instance.latest_deploy_time)
  }
end

# == Schema Information
#
# Table name: patch_notes
#
#  id                  :bigint           not null, primary key
#  note                :text             not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  patch_note_group_id :bigint           not null
#  patch_note_type_id  :bigint           not null
#
# Indexes
#
#  index_patch_notes_on_patch_note_group_id  (patch_note_group_id)
#  index_patch_notes_on_patch_note_type_id   (patch_note_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (patch_note_group_id => patch_note_groups.id)
#  fk_rails_...  (patch_note_type_id => patch_note_types.id)
#
