class LearningHour < ApplicationRecord
  
  belongs_to :user

  enum learning_type: {
    book: 1,
    movie: 2, 
    webinar: 3,
    conference: 4,
    other: 5
  }

  
end

# == Schema Information
#
# Table name: learning_hours
#
#  id               :bigint           not null, primary key
#  duration_hours   :integer
#  duration_minutes :integer          not null
#  learning_type    :integer          default("other")
#  name             :string
#  occurred_at      :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_learning_hours_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
