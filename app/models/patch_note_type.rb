class PatchNoteType < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: true, presence: true
end

# == Schema Information
#
# Table name: patch_note_types
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_patch_note_types_on_name  (name) UNIQUE
#
