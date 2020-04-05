class CasaCase < ApplicationRecord
  has_paper_trail

  has_many :case_assignments
  has_many(
    :volunteers,
    through: :case_assignments,
    source: :volunteer,
    class_name: "User"
  )
  validates :case_number, uniqueness: { case_sensitive: false }, presence: true

  scope :ordered, -> { sort_by(&:updated_at).reverse }
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                    :bigint           not null, primary key
#  case_number           :string           not null
#  teen_program_eligible :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_casa_cases_on_case_number  (case_number) UNIQUE
#
