class LoginActivity < ApplicationRecord
  belongs_to :user, polymorphic: true, optional: true
end

# == Schema Information
#
# Table name: login_activities
#
#  id             :bigint           not null, primary key
#  city           :string
#  context        :string
#  country        :string
#  failure_reason :string
#  identity       :string
#  ip             :string
#  latitude       :float
#  longitude      :float
#  referrer       :text
#  region         :string
#  scope          :string
#  strategy       :string
#  success        :boolean
#  user_agent     :text
#  user_type      :string
#  created_at     :datetime
#  user_id        :bigint
#
