class PreferenceSet < ApplicationRecord
  belongs_to :user
end

# == Schema Information
#
# Table name: preference_sets
#
#  id                     :bigint           not null, primary key
#  case_volunteer_columns :jsonb            not null
#  table_state            :jsonb
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint
#
# Indexes
#
#  index_preference_sets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
