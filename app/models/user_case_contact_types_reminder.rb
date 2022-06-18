class UserCaseContactTypesReminder < ApplicationRecord
  belongs_to :user
end

# == Schema Information
#
# Table name: user_case_contact_types_reminders
#
#  id            :bigint           not null, primary key
#  reminder_sent :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_user_case_contact_types_reminders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
