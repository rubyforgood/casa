class UserReminderTime < ApplicationRecord
  belongs_to :user
end

# == Schema Information
#
# Table name: user_reminder_times
#
#  id                 :bigint           not null, primary key
#  case_contact_types :datetime
#  no_contact_made    :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :bigint           not null
#
# Indexes
#
#  index_user_reminder_times_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
