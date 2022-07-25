class PatchNoteGroup < ApplicationRecord
  validates :value, uniqueness: true, presence: true
end

# == Schema Information
#
# Table name: patch_note_groups
#
#  id         :bigint           not null, primary key
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_patch_note_groups_on_value  (value) UNIQUE
#
