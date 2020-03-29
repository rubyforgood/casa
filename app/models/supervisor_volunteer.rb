class SupervisorVolunteer < ApplicationRecord
end

# == Schema Information
#
# Table name: supervisor_volunteers
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  supervisor_user_id :integer
#  volunteer_user_id  :integer
#
