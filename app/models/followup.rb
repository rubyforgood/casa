class Followup < ApplicationRecord
  belongs_to :case_contact
  belongs_to :creator, class_name: "User"

  enum status: {requested: 0, resolved: 1}
end

# == Schema Information
#
# Table name: followups
#
#  id              :bigint           not null, primary key
#  status          :integer          default("requested")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  case_contact_id :bigint
#  creator_id      :bigint
#
# Indexes
#
#  index_followups_on_case_contact_id  (case_contact_id)
#  index_followups_on_creator_id       (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#
