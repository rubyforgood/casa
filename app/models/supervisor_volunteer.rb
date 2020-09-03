class VolunteerSingleSupervisorValidator < ActiveModel:: Validator 
  def validate(record)
    if SupervisorVolunteer.where(volunteer_id: record.volunteer_id, is_active: true).size >= 1
      record.errors[:base] << "A volunteer cannot have more than 1 supervisor"
    end
  end
end

# relationship between a supervisor and volunteer
class SupervisorVolunteer < ApplicationRecord
  has_paper_trail
  belongs_to :volunteer, class_name: "User"
  belongs_to :supervisor, class_name: "User"
  validates :supervisor_id, uniqueness: {scope: :volunteer_id} # only 1 row allowed per supervisor-volunteer pair
  validates_with VolunteerSingleSupervisorValidator
end

# == Schema Information
#
# Table name: supervisor_volunteers
#
#  id            :bigint           not null, primary key
#  is_active     :boolean          default(TRUE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  supervisor_id :bigint           not null
#  volunteer_id  :bigint           not null
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