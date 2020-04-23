class CasaCase < ApplicationRecord
  has_paper_trail

  has_many :case_assignments
  has_many(:volunteers, through: :case_assignments, source: :volunteer, class_name: 'User')
  has_many :case_contacts
  validates :case_number, uniqueness: { case_sensitive: false }, presence: true

  scope :ordered, -> { sort_by(&:updated_at).reverse }
  scope :actively_assigned_to,
        lambda { |volunteer|
          joins(:case_assignments).where(
            case_assignments: { volunteer: volunteer, is_active: true }
          )
        }
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                    :bigint           not null, primary key
#  case_number           :string           not null
#  transition_aged_youth :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_casa_cases_on_case_number  (case_number) UNIQUE
#
