class ChecklistItem < ApplicationRecord
  belongs_to :hearing_type
  has_one :casa_org, through: :hearing_type
  validates :category, presence: true
  validates :description, presence: true
end

# == Schema Information
#
# Table name: checklist_items
#
#  id              :bigint           not null, primary key
#  category        :string           not null
#  description     :text             not null
#  mandatory       :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  hearing_type_id :integer
#
# Indexes
#
#  index_checklist_items_on_hearing_type_id  (hearing_type_id)
#
