class CaseAssignment < ApplicationRecord
  belongs_to :casa_case
  belongs_to :volunteer, class_name: "User"

  validates :casa_case_id, uniqueness: {scope: :volunteer_id} # only 1 row allowed per case-volunteer pair
  validates :volunteer, presence: true
  validate :assignee_must_be_volunteer
  validate :casa_case_and_volunteer_must_belong_to_same_casa_org, if: -> { casa_case.present? && volunteer.present? }

  scope :is_active, -> { where(is_active: true) }
  scope :active, -> { where(active: true) }

  def self.inactive_this_week(volunteer_id)
    where("updated_at > ?", 1.week.ago).where(active: false).where(volunteer_id: volunteer_id)
  end

  def inactive? = !active?

  private

  def assignee_must_be_volunteer
    errors.add(:volunteer, "Case assignee must be an active volunteer") unless volunteer.is_a?(Volunteer) && volunteer.active?
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
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE), not null
#  allow_reimbursement :boolean          default(TRUE)
#  hide_old_contacts   :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  casa_case_id        :bigint           not null
#  volunteer_id        :bigint           not null
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
