class SupervisorVolunteer < ApplicationRecord
end

# == Schema Information
#
# Table name: supervisor_volunteers
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  supervisor_user_id :bigint
#  volunteer_user_id  :bigint
#
# Indexes
#
#  index_supervisor_volunteers_on_supervisor_user_id  (supervisor_user_id)
#  index_supervisor_volunteers_on_volunteer_user_id   (volunteer_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (supervisor_user_id => users.id)
#  fk_rails_...  (volunteer_user_id => users.id)
#
