# relationship between a supervisor and volunteer
class SupervisorVolunteer < ApplicationRecord
  belongs_to :volunteer, class_name: "User"
  belongs_to :supervisor, class_name: "User"

  validates :supervisor_id, uniqueness: {scope: :volunteer_id}
  validates :volunteer_id, uniqueness: {scope: :is_active}, if: :is_active?
  validate :ensure_supervisor_and_volunteer_belong_to_same_casa_org, if: -> { supervisor.present? && volunteer.present? }

  private

  def ensure_supervisor_and_volunteer_belong_to_same_casa_org
    return if supervisor.casa_org_id == volunteer.casa_org_id

    errors.add(:volunteer, "and supervisor must belong to the same organization")
  end
end

# == Schema Information
#
# Table name: supervisor_volunteers
#
#  id            :bigint           not null, primary key
#  is_active     :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  supervisor_id :integer          not null
#  volunteer_id  :integer          not null
#
# Indexes
#
#  index_supervisor_volunteers_on_supervisor_id  (supervisor_id)
#  index_supervisor_volunteers_on_volunteer_id   (volunteer_id)
#
# Foreign Keys
#
#  fk_rails_...  (supervisor_id => users.id)
#  fk_rails_...  (volunteer_id => users.id)
#
