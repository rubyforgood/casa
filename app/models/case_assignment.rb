class CaseAssignment < ApplicationRecord
  has_paper_trail

  belongs_to :casa_case
  belongs_to :volunteer, class_name: "User", inverse_of: "case_assignments"
  has_many :cases_where_contact_made_in_14_days, lambda {
    joins(:case_contacts)
      .where(case_contacts: {contact_made: true})
      .where("case_contacts.occurred_at > ?", Date.current - 14.days)
    # this should respect current vs past cases
  }, class_name: "CasaCase", primary_key: :casa_case_id, foreign_key: :id

  validates :casa_case_id, uniqueness: {scope: :volunteer_id} # only 1 row allowed per case-volunteer pair
  validates :volunteer, presence: true
  validate :assignee_must_be_volunteer
  validate :casa_case_and_volunteer_must_belong_to_same_casa_org, if: -> { casa_case.present? && volunteer.present? }

  scope :is_active, -> { where(is_active: true) }

  private

  def assignee_must_be_volunteer
    errors.add(:volunteer, "Case assignee must be a volunteer") unless volunteer.is_a?(Volunteer) && volunteer.active?
  end

  def casa_case_and_volunteer_must_belong_to_same_casa_org
    return if casa_case.casa_org_id == volunteer.casa_org_id

    errors.add(:volunteer, "and case must belong to the same organization")
  end
end

# == Schema Information
#
# Table name: case_assignments
#
#  id           :bigint           not null, primary key
#  is_active    :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  casa_case_id :bigint           not null
#  volunteer_id :bigint           not null
#
# Indexes
#
#  index_case_assignments_on_casa_case_id  (casa_case_id)
#  index_case_assignments_on_volunteer_id  (volunteer_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (volunteer_id => users.id)
#
