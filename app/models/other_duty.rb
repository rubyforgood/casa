class OtherDuty < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  delegate :type, to: :creator, prefix: true
end

# == Schema Information
#
# Table name: other_duties
#
#  id               :bigint           not null, primary key
#  creator_type     :string
#  duration_minutes :bigint
#  notes            :text
#  occurred_at      :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  creator_id       :bigint           not null
#
